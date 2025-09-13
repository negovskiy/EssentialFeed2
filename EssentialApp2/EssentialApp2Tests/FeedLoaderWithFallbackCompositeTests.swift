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
    let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let remoteFeed = uniqueFeed()
        let localFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(remoteFeed), fallbackResult: .success(localFeed))
        
        expect(sut, toCompleteWith: .success(remoteFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let localFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(localFeed))
        
        expect(sut, toCompleteWith: .success(localFeed))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: FeedLoader,
        toCompleteWith expectedResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for loading to complete.")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case (.failure, .failure):
                break
                
            default: XCTFail("Unexpected result", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func trackForMemoryLeaks<T: AnyObject>(
        _ object: T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(
                object,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0, userInfo: nil)
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
