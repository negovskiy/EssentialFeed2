//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import XCTest
import EssentialFeed2

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.saveImageData(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveImageDataForURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeaallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResults: [LocalFeedImageDataLoader.SaveResult] = []
        sut?.saveImageData(anyData(), for: anyURL()) {
            receivedResults.append($0)
        }
        
        sut = nil
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no completion, but got \(receivedResults)")
    }
    
    // MARK: - Helpers
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: String = #file,
        line: UInt = #line
    ) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy)  {
        let storeSpy = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: storeSpy)
        
        trackForMemoryLeaks(storeSpy)
        trackForMemoryLeaks(sut)
        
        return (sut, storeSpy)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.saveImageData(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
