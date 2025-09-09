//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/1/25.
//

import XCTest
import EssentialFeed2

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(data), when: {
            store.completeRetrieval(with: data)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) {
            received.append($0)
        }
        task.cancel()
        
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no completion, but got \(received) instead.")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) {
            received.append($0)
        }
        
        sut = nil
        store.completeRetrieval(with: .none)
        
        XCTAssertTrue(received.isEmpty, "Expected no completion, but got \(received) instead.")
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
    
    private func failed() -> LocalFeedImageDataLoader.LoadResult {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> LocalFeedImageDataLoader.LoadResult {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (
                .failure(receivedError as LocalFeedImageDataLoader.LoadError),
                .failure(expectedError as LocalFeedImageDataLoader.LoadError)
            ):
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

