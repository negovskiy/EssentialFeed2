//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/10/25.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            let result = Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed($0.localFeed, $0.timestamp)
                }
            }
            completion(result)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, _ completion: @escaping InsertionCompletion) {
        performAsync { context in
            let result = Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            }
            completion(result)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete)
            })
        }
    }
}
