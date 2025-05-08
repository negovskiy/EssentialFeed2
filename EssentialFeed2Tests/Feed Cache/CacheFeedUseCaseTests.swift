//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/8/25.
//

import XCTest
import EssentialFeed2

class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveItems(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.saveItems(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        .init(
            id: UUID(),
            description: "any",
            location: "any",
            imageURL: anyURL()
        )
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
