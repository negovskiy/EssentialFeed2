//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 8/1/25.
//

import XCTest
import EssentialFeed2

class RemoteFeedImageDataLoader {
    init(client: Any) {}
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        RemoteFeedImageDataLoader,
        HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        let requestedURLs: [URL] = []
    }
}
