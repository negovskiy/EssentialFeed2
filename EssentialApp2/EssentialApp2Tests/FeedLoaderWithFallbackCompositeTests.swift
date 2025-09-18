//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/13/25.
//

import XCTest
import EssentialFeed2
import EssentialApp2

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
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
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailures() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
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
}
