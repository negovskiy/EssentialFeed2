//
//  XCTestCase+FeedLoaderTestCase.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/18/25.
//

import XCTest
import EssentialFeed2

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: Swift.Result<[FeedImage], Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedResult = Result { try sut.load() }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedFeed), .success(expectedFeed)):
            XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
        case (.failure, .failure):
            break
            
        default: XCTFail("Unexpected result", file: file, line: line)
        }
        
    }
}
