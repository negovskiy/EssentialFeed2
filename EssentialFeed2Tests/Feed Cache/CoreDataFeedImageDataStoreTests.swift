//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import XCTest
import EssentialFeed2

extension CoreDataFeedStore: @retroactive FeedImageDataStore {
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping (FeedImageDataStore.InsertionResult) -> Void
    ) {
        
    }
    
    public func retrieve(
        dataFor url: URL,
        completion: @escaping (
            FeedImageDataStore.RetrievalResult
        ) -> Void
    ) {
        completion(.success(.none))
    }
}

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
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
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
