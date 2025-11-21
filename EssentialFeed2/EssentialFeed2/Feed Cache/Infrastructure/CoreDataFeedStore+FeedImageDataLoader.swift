//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL) throws {
        try ManagedFeedImage.first(with: url, in: context)
            .map { $0.data = data }
            .map { try context.save() }
    }
    
    public func retrieve(dataFor url: URL) throws -> Data? {
        try ManagedFeedImage.data(with: url, in: context)
    }
}
