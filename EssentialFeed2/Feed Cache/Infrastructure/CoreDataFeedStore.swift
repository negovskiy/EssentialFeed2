//
//  CoreDataFeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/30/25.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            let result = Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed($0.localFeed, $0.timestamp)
                }
            }
            completion(result)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, _ completion: @escaping InsertionCompletion) {
        perform { context in
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
        perform { context in
            let result: Result<Void, Error> = Result {
                try ManagedCache.find(in: context).map(context.delete)
            }
            completion(result)
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
