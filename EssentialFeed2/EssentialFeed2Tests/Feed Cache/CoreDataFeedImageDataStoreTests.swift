//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import XCTest
import EssentialFeed2

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
        try makeSUT { sut in
            expect(sut, toCompleteRetrievedWith: notFound(), for: anyURL())
        }
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() throws {
        try makeSUT { sut in
            let url = anyURL()
            let nonMatchingURL = URL(string: "https://another-url.com")!
            
            insert(anyData(), for: url, into: sut)
            
            expect(sut, toCompleteRetrievedWith: notFound(), for: nonMatchingURL)
        }
    }
    
    func test_retrieveImageData_deliversFoundDataWhenStoreHasDataForMatchingURL() throws {
        try makeSUT { sut in
            let matchingURL = anyURL()
            let storedData = anyData()
            
            insert(storedData, for: matchingURL, into: sut)
            
            expect(sut, toCompleteRetrievedWith: found(storedData), for: matchingURL)
        }
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() throws {
        try makeSUT { sut in
            let matchingURL = anyURL()
            let firstData = Data("first chunk".utf8)
            let secondData = Data("first chunk".utf8)
            
            insert(firstData, for: matchingURL, into: sut)
            insert(secondData, for: matchingURL, into: sut)
            
            expect(sut, toCompleteRetrievedWith: found(secondData), for: matchingURL)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ action: (CoreDataFeedStore) throws -> Void
    ) throws {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        try action(sut)
    }
}

private func notFound() -> Result<Data?, Error> {
    .success(.none)
}

private func found(_ data: Data) -> Result<Data?, Error> {
    .success(data)
}

private func localImage(url: URL) -> LocalFeedImage {
    .init(id: UUID(), description: "any", location: "any", url: url)
}

private func expect(
    _ sut: CoreDataFeedStore,
    toCompleteRetrievedWith expectedResult: Result<Data?, Error>,
    for url: URL,
    file: StaticString = #file,
    line: UInt = #line
) {
    let receivedResult = Result { try sut.retrieve(dataFor: url) }
    switch (receivedResult, expectedResult) {
    case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, "Data should match", file: file, line: line)
    default:
        XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
    }
}

private func insert(
    _ data: Data,
    for url: URL,
    into sut: CoreDataFeedStore,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let image = localImage(url: url)
        try sut.insert([image], .now)
        try sut.insert(data, for: url)
    } catch  {
        XCTFail("Failed to insert data: \(error)", file: file, line: line)
    }
}

