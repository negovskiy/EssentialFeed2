//
//  InMemoryFeedStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 12/5/25.
//

import Foundation

@MainActor
public class InMemoryFeedStore {
	private var feedCache: CachedFeed?
	private var feedImageDataCache = NSCache<NSURL, NSData>()
	
	public init() {}
}

extension InMemoryFeedStore: FeedStore {
	public func deleteCachedFeed() throws {
		feedCache = nil
	}

    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date) throws {
		feedCache = CachedFeed(feed: feed, timestamp: timestamp)
	}

	public func retrieve() throws -> CachedFeed? {
		feedCache
	}
}

extension InMemoryFeedStore: FeedImageDataStore {
	public func insert(_ data: Data, for url: URL) throws {
		feedImageDataCache.setObject(data as NSData, forKey: url as NSURL)
	}
	
    public func retrieve(dataFor url: URL) throws -> Data? {
		feedImageDataCache.object(forKey: url as NSURL) as Data?
	}
}
