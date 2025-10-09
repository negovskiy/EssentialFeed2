//
//  ImageCommentsMapperTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import XCTest
import EssentialFeed2

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon2xxHTTPResponse() {
        let samples = [199, 100, 300, 400, 500]
        
        for code in samples {
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(makeItemsJSON([]), HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() {
        let samples = [200, 201, 205, 250, 299]
        let invalidJSON = Data("Invalid JSON".utf8)
        
        for code in samples {
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSON() throws {
        let samples = [200, 201, 205, 250, 299]
        let emptyListJSON = makeItemsJSON([])
        
        for code in samples {
            let result = try ImageCommentsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSON() throws {
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
        
        let samples = [200, 201, 205, 250, 299]
        let jsonData = makeItemsJSON([item1.json, item2.json])
        
        for code in samples {
            let result = try ImageCommentsMapper.map(jsonData, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    
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
}
