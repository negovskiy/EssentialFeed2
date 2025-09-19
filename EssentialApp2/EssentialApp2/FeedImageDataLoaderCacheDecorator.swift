//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import Foundation
import EssentialFeed2

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.saveIgnoringResult(data, for: url)
            }
            completion(result)
        }
    }
}

private extension FeedImageDataLoaderCacheDecorator {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        cache.saveImageData(data, for: url, completion: { _ in })
    }
}
