//
//  NullStore.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 11/11/25.
//

import Foundation
import EssentialFeed2

public class NullStore: FeedStore & FeedImageDataStore {
    public func insert(_ feed: [EssentialFeed2.LocalFeedImage], _ timestamp: Date) throws {}
    public func retrieve() throws -> EssentialFeed2.CachedFeed? { .none }
    public func deleteCachedFeed() throws {}
    
    public func insert(_ data: Data, for url: URL) throws {}
    public func retrieve(dataFor url: URL) throws -> Data? { .none }
    public func save(_ imageData: Data, for itemID: String) throws { }
}
