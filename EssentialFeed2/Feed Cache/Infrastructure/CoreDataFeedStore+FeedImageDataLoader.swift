//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping (FeedImageDataStore.InsertionResult) -> Void
    ) {
        
    }
    
    public func retrieve(
        dataFor url: URL,
        completion: @escaping (
            FeedImageDataStore.RetrievalResult
        ) -> Void
    ) {
        completion(.success(.none))
    }
}
