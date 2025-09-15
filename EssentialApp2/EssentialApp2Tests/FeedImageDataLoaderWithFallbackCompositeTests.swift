//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/15/25.
//

import XCTest
import EssentialFeed2

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primary: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping (
            FeedImageDataLoader.Result
        ) -> Void
    ) -> any EssentialFeed2.FeedImageDataLoaderTask {
        primary.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversPrimaryResultOnPrimarySuccess() {
        let primaryData = Data("primary data".utf8)
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .failure(anyNSError()))
        let url = anyURL()
        
        let exp = XCTestExpectation(description: "Wait for loading to complete")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, primaryData)
            case .failure:
                XCTFail("Expected to succeed, but it failed")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedImageDataLoaderWithFallbackComposite {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader,
            fallback: fallbackLoader
        )
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class FeedImageDataLoaderStub: FeedImageDataLoader {
        private class TaskWrapper: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> any EssentialFeed2.FeedImageDataLoaderTask {
            completion(result)
            return TaskWrapper()
        }
    }
}
