//
//  FeedItemsMapperTests.swift
//  EssentialFeed2Tests
//
//  Created by Andrey Negovskiy on 4/19/25.
//

import XCTest
import EssentialFeed2

final class FeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() {
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            XCTAssertThrowsError(
                try FeedItemsMapper.map(makeItemsJSON([]), HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("Invalid JSON".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemsJSON([])
        let result = try FeedItemsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSON() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "description",
            location: "location",
            imageURL: URL(string: "https://another-url.com")!
        )
        
        let jsonData = makeItemsJSON([item1.json, item2.json])
        let result = try FeedItemsMapper.map(jsonData, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    private func makeItem(
        id: UUID = UUID(),
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode code: Int) {
        self.init(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
