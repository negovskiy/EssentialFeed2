//
//  EssentialFeed2CacheIntegrationTests.swift
//  EssentialFeed2CacheIntegrationTests
//
//  Created by Andrey Negovskiy on 6/6/25.
//

import XCTest
import EssentialFeed2

final class EssentialFeed2CacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnSeparateInstance() throws {
        
        let sutToPerformSave = try makeSUT()
        let sutToPerformLoad = try makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
        
        expect(sutToPerformLoad, toLoad: feed)
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
    
    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(
                    loadedFeed,
                    expectedFeed,
                    "Expected empty feed, got \(loadedFeed) instead"
                )
                
            case let .failure(error):
                XCTFail("Expected success, got failure \(error) instead")
                
            @unknown default:
                XCTFail( "Unknown error")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectoryURL().appendingPathComponent("\(type(of: Self.self)).store")
    }
    
    private func cachesDirectoryURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
