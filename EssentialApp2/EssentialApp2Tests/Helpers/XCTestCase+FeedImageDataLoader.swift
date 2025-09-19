//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import XCTest
import EssentialFeed2
import EssentialApp2

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    func expect(
        _ sut: FeedImageDataLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = XCTestExpectation(description: "Wait for loading to complete")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(
                    expectedData,
                    receivedData,
                    "Expected and received data do not match",
                    file: file,
                    line: line
                )
            
            case (.failure, .failure):
                break
            default:
                XCTFail(
                    "Expected \(expectedResult), but got \(receivedResult)",
                    file: file,
                    line: line
                )
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
}
