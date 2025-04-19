//
//  RemoteFeedLoaderTests.swift
//  EssentialFeed2Tests
//
//  Created by Andrey Negovskiy on 4/19/25.
//

import XCTest
import EssentialFeed2

final class RemoteFeedLoaderTests: XCTestCase {

    func test_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-specific-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestURL: URL?
        
        func get(from url: URL) {
            requestURL = url
        }
    }

}
