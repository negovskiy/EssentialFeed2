//
//  CoreDataFeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/30/25.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init () { }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, _ completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
