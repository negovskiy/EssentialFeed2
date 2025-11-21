//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/10/25.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve() throws -> CachedFeed? {
        try ManagedCache.find(in: context).map {
            CachedFeed($0.localFeed, $0.timestamp)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date) throws {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
        try context.save()
    }
    
    public func deleteCachedFeed() throws {
        try ManagedCache.find(in: context).map(context.delete)
    }
}
