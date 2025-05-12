//
//  FeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public enum RetrievedCacheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievedCacheFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], _ timestamp: Date, _ completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
