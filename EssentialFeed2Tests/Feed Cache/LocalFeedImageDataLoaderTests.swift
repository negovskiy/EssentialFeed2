//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/1/25.
//

import XCTest
import EssentialFeed2

protocol FeedImageDataStore {
    func retrieve(dataFor url: URL)
    
}

class LocalFeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping ((FeedImageDataLoader.Result) -> Void)
    ) -> FeedImageDataLoaderTask {
        store.retrieve(dataFor: url)
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
    
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages: [Message] = []
        
        func retrieve(dataFor url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}

