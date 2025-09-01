//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/1/25.
//

import XCTest
import EssentialFeed2

class LocalFeedImageDataLoader {
    init(store: Any) {}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: String = #file,
        line: UInt = #line
    ) -> (LocalFeedImageDataLoader, FeedStoreSpy)  {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let receivedMessages: [Any] = []
    }
}

