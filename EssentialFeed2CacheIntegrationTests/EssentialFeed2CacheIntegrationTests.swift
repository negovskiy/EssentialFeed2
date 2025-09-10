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
        let sut = try makeFeedLoader()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnSeparateInstance() throws {
        let sutToPerformSave = try makeFeedLoader()
        let sutToPerformLoad = try makeFeedLoader()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() throws {
        let sutToPerformFirstSave = try makeFeedLoader()
        let sutToPerformSecondSave = try makeFeedLoader()
        let sutToPerformLoad = try makeFeedLoader()
        
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformSecondSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = try! makeImageLoader()
        let imageLoaderToPerformLoad = try! makeImageLoader()
        let feedLoader = try! makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(currentDate: Date.init, store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeImageLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedImageDataLoader {
        
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        
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
                    "Expected empty feed, got \(loadedFeed) instead",
                    file: file,
                    line: line
                )
                
            case let .failure(error):
                XCTFail(
                    "Expected success, got failure \(error) instead",
                    file: file,
                    line: line
                )
                
            @unknown default:
                XCTFail(
                    "Unknown error",
                    file: file,
                    line: line
                )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(
        _ feed: [FeedImage],
        with sut: LocalFeedLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .success:
                break
                
            case let .failure(error):
                XCTFail(
                    "Expected to save feed successfully, got \(error)",
                    file: file,
                    line: line
                )
            }
        
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toLoad expectedData: Data,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(
                    loadedData,
                    expectedData,
                    "Expected empty feed, got \(loadedData) instead",
                    file: file,
                    line: line
                )
                
            case let .failure(error):
                XCTFail(
                    "Expected success, got failure \(error) instead",
                    file: file,
                    line: line
                )
                
            @unknown default:
                XCTFail(
                    "Unknown error",
                    file: file,
                    line: line
                )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(
        _ data: Data,
        for url: URL,
        with sut: LocalFeedImageDataLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let saveExp = expectation(description: "Wait for save completion")
        sut.saveImageData(data, for: url) { result in
            switch result {
            case .success:
                break
                
            case let .failure(error):
                XCTFail(
                    "Expected to save feed successfully, got \(error)",
                    file: file,
                    line: line
                )
            }
        
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
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
