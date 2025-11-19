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
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() throws {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        try sut.saveImageData(data, for: url)
        
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
    
    private func failed() -> Result<Void, Error> {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: Result<Void, Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        
        let receivedResult = Result { try sut.saveImageData(anyData(), for: anyURL()) }
        
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
            
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(
                receivedError as NSError,
                expectedError as NSError,
                file: file,
                line: line
            )
            
        default:
            XCTFail("Expected result \(expectedResult) but got \(receivedResult)", file: file, line: line)
        }
    }
}
