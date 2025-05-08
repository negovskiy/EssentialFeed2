//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/8/25.
//

import XCTest
import EssentialFeed2

class LocalFeedLoader {
    
    private let currentDate: () -> Date
    private let store: FeedStore
    
    init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }
    
    func save(_ items: [FeedItem], _ completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            completion(error)
            
            if error == nil {
                self.store.insert(items, self.currentDate())
            }
        }
    }
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void

    private var deletionCompletions: [DeletionCompletion] = []
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error? = nil, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], _ timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeleteError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion")
        
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as? NSError, deletionError)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
