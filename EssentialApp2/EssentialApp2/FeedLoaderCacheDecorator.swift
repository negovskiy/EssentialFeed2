//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/18/25.
//

import EssentialFeed2

public class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.saveIgnoringResult(feed)
            }
            completion(result)
        }
    }
}

private extension FeedLoaderCacheDecorator {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        cache.save(feed) { _ in }
    }
}
