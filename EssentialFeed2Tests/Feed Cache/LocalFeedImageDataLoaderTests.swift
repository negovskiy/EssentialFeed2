//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/1/25.
//

import XCTest
import EssentialFeed2

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFor url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping ((FeedImageDataLoader.Result) -> Void)
    ) -> FeedImageDataLoaderTask {
        store.retrieve(dataFor: url) { result in
            completion(
                result
                    .mapError { _ in Error.failed }
                    .flatMap { data in
                        data.map { .success($0) } ?? .failure(Error.notFound)
                    }
            )
        }
        
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
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
            store.complete(with: retrievalError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(data), when: {
            store.complete(with: data)
        })
    }
    
    // MARK: - Helpers
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: String = #file,
        line: UInt = #line
    ) -> (LocalFeedImageDataLoader, StoreSpy)  {
        let storeSpy = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: storeSpy)
        
        trackForMemoryLeaks(storeSpy)
        trackForMemoryLeaks(sut)
        
        return (sut, storeSpy)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
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
                .failure(receivedError as LocalFeedImageDataLoader.Error),
                .failure(expectedError as LocalFeedImageDataLoader.Error)
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
    
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages: [Message] = []
        private var completions: [(FeedImageDataStore.Result) -> Void] = []
        
        func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            completions.append(completion)
            receivedMessages.append(.retrieve(dataFor: url))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}

