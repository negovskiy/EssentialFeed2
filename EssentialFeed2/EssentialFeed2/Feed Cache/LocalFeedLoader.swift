//
//  LocalFeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public final class LocalFeedLoader {
    
    private let currentDate: () -> Date
    private let store: FeedStore
        
    public init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try cache(feed)
    }
    
    private func cache(_ feed: [FeedImage]) throws {
        try store.insert(feed.toLocal(), self.currentDate())
    }
}

extension LocalFeedLoader {
    public func load() throws -> [FeedImage] {
        let cache = try store.retrieve()
        if let cache, FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.feed.toModels()
        }
        
        return []
    }
}

extension LocalFeedLoader {
    
    public struct InvalidCache: Error {}
    
    public func validateCache() throws {
        do {
            let cache = try store.retrieve()
            if let cache, !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map {
            .init(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            .init(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
