//
//  CodableFeedStoreTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/21/25.
//

import XCTest
import EssentialFeed2

class CodableFeedStore {
    
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, url: url)
        }
        
        init(_ localFeedImage: LocalFeedImage) {
            id = localFeedImage.id
            description = localFeedImage.description
            location = localFeedImage.location
            url = localFeedImage.url
        }
    }
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map(\.local)
        }
    }
    
    private let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let cache = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], _ timestamp: Date, _ completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty feed, got: \n\t\(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected empty feed twice in a row, got: \n\t\(firstResult)\n\t\(secondResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for completion")
        sut.insert(feed, timestamp) { insertResult in
            XCTAssertNil(insertResult, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected to find inserted feed, got: \n\t\(retrieveResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
}
