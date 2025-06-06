//
//  EssentialFeed2CacheIntegrationTests.swift
//  EssentialFeed2CacheIntegrationTests
//
//  Created by Andrey Negovskiy on 6/6/25.
//

import XCTest
import EssentialFeed2

final class EssentialFeed2CacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items, [], "Expected empty feed, got \(items) instead")
                
            case let .failure(error):
                XCTFail("Expected success, got failure \(error) instead")
                
            @unknown default:
                XCTFail( "Unknown error")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(currentDate: Date.init, store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectoryURL().appendingPathComponent("\(type(of: Self.self)).store")
    }
    
    private func cachesDirectoryURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
