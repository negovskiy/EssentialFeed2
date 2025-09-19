//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import XCTest
import EssentialFeed2

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = Data("data to receive".utf8)
        let imageLoader = FeedImageDataLoaderStub(result: .success(data))
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: imageLoader)
        
        expect(sut, toCompleteWith: .success(data)) {
            imageLoader.completeLoading()
        }
    }
    
    func test_loadImageData_deliversFailureOnLoaderFailure() {
        let imageLoader = FeedImageDataLoaderStub(result: .failure(anyNSError()))
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: imageLoader)
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            imageLoader.completeLoading()
        }
    }
}
