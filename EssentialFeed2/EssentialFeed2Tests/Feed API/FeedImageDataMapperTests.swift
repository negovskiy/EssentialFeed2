//
//  FeedImageDataMapperTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 8/1/25.
//

import XCTest
import EssentialFeed2

class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() {
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithEmptyData() {
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(Data(), HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty-data".utf8)
        
        let mappedData = try FeedImageDataMapper.map(nonEmptyData, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(nonEmptyData, mappedData)
    }
}
