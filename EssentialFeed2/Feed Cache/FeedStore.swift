//
//  FeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], _ timestamp: Date, _ completion: @escaping InsertionCompletion)
}
