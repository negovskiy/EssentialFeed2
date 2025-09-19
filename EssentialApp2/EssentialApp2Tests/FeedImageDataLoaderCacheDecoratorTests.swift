//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import XCTest
import EssentialFeed2
import EssentialApp2

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = Data("data to receive".utf8)
        let (sut, loader, _) = makeSUT(expectedResult: .success(data))
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.completeLoading()
        }
    }
    
    func test_loadImageData_deliversFailureOnLoaderFailure() {
        let (sut, loader, _) = makeSUT(expectedResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.completeLoading()
        }
    }
    
    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let data = Data("data to cache".utf8)
        let url = URL(string: "https://a-specific-url.com")!
        let (sut, loader, cache) = makeSUT(expectedResult: .success(data))
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        loader.completeLoading()
        
        XCTAssertEqual(cache.messages, [.save(data, url)], "Expected to cache the loaded data")
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let (sut, loader, cache) = makeSUT(expectedResult: .failure(anyNSError()))
        
        _ = sut.loadImageData(from: anyURL(), completion: { _ in })
        loader.completeLoading()
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected no cache interactions, but got: \(cache.messages)")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        expectedResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageDataLoader, FeedImageDataLoaderStub, CacheSpy) {
        let imageLoader = FeedImageDataLoaderStub(result: expectedResult)
        let cache = CacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(
            decoratee: imageLoader,
            cache: cache
        )
        
        trackForMemoryLeaks(imageLoader)
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, imageLoader, cache)
    }
    
    private class CacheSpy: FeedImageDataCache {
        enum SaveError: Swift.Error {
            case failed
        }
        
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        private(set) var messages = [Message]()
        
        func saveImageData(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data, url))
            completion(.success(()))
        }
    }
}
