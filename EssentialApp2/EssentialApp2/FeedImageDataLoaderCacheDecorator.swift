//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import Foundation
import EssentialFeed2

public class FeedImageDataLoaderCacheDecorator<Cache: FeedImageDataCache>: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: Cache
    
    public init(decoratee: FeedImageDataLoader, cache: Cache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.saveImageData(data, for: url, completion: { _ in })
            }
            completion(result)
        }
    }
}
