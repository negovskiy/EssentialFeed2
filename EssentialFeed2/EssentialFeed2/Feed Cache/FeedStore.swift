//
//  FeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], _ timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}
