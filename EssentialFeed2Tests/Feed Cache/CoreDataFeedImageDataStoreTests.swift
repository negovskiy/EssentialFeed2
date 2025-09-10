//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import XCTest
import EssentialFeed2

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = try! makeSUT()
        
        expect(sut, toCompleteRetrievedWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() {
        let sut = try! makeSUT()
        let url = anyURL()
        let nonMatchingURL = URL(string: "https://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievedWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenStoreHasDataForMatchingURL() {
        let sut = try! makeSUT()
        let matchingURL = anyURL()
        let storedData = anyData()
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievedWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = try! makeSUT()
        let matchingURL = anyURL()
        let firstData = Data("first chunk".utf8)
        let secondData = Data("first chunk".utf8)
        
        insert(firstData, for: matchingURL, into: sut)
        insert(secondData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievedWith: found(secondData), for: matchingURL)
    }
    
    func test_sideEffects_runSerially() {
        let sut = try! makeSUT()
        let url = anyURL()
        
        let firstExpectation = expectation(description: "First")
        sut.insert([localImage(url: url)], .now) { _ in firstExpectation.fulfill() }
        
        let secondExpectation = expectation(description: "Second")
        sut.insert(anyData(), for: url) { _ in secondExpectation.fulfill() }
        
        let thirdExpectation = expectation(description: "Third")
        sut.insert(anyData(), for: url) { _ in thirdExpectation.fulfill() }
            
        wait(
            for: [firstExpectation, secondExpectation, thirdExpectation],
            timeout: 5,
            enforceOrder: true
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        .success(data)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        .init(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrievedWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        sut.retrieve(dataFor: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Data should match", file: file, line: line)
                exp.fulfill()
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for insertion to complete")
        let image = localImage(url: url)
        
        sut.insert([image], .now) { result in
            switch result {
            case .success:
                sut.insert(data, for: url) { result in
                    if case let .failure(error) = result {
                        XCTFail("Failed to insert data: \(error)", file: file, line: line)
                    }
                }
            case let .failure(error):
                XCTFail("Failed to insert: \(error)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
