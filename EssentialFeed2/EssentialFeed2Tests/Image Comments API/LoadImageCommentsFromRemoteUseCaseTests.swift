//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import XCTest
import EssentialFeed2

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 100, 300, 400, 500]
        
        for (index, code) in samples.enumerated() {
            expect(sut, toCompleteWithResult: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeItemsJSON([]), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 205, 250, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut, toCompleteWithResult: failure(.invalidData), when: {
                let invalidJSON = Data("Invalid JSON".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 205, 250, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut, toCompleteWithResult: .success([]), when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (
                date: Date(timeIntervalSince1970: 1759476215),
                iso8601String: "2025-10-03T07:23:35+00:00"
            ),
            username: "a username"
        )
        
        let item2 = makeItem(
            id: UUID(),
            message: "a second message",
            createdAt: (
                date: Date(timeIntervalSince1970: 1759476215),
                iso8601String: "2025-10-03T07:23:35+00:00"
            ),
            username: "another username"
        )
        
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 205, 250, 299]
        
        for (index, code) in samples.enumerated() {
            expect(sut, toCompleteWithResult: .success(items)) {
                let jsonData = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (RemoteImageCommentsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
    
    private func makeItem(
        id: UUID = UUID(),
        message: String,
        createdAt: (date: Date, iso8601String: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": ["username": username]
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        _ sut: RemoteImageCommentsLoader,
        toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
