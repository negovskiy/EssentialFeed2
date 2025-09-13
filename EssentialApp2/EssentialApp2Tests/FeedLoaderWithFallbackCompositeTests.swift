//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/13/25.
//

import XCTest
import EssentialFeed2

class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let remoteFeed = uniqueFeed()
        let localFeed = uniqueFeed()
        let primaryLoader = FeedLoaderStub(result: .success(remoteFeed))
        let fallbackLoader = FeedLoaderStub(result: .success(localFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for loading to complete.")
        
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, remoteFeed)
                
            case .failure:
                XCTFail("Expected to succeed but got failure instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        [
            FeedImage(
                id: UUID(),
                description: "description",
                location: "location",
                url: URL(string: "http://a-url.com")!
            )
        ]
    }
    
    private class FeedLoaderStub: FeedLoader {
        let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
