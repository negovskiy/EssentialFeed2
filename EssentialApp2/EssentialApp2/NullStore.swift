//
//  NullStore.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 11/11/25.
//

import Foundation
import EssentialFeed2

public class NullStore: FeedStore & FeedImageDataStore {
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    public func insert(_ feed: [EssentialFeed2.LocalFeedImage], _ timestamp: Date, _ completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func save(_ imageData: Data, for itemID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
