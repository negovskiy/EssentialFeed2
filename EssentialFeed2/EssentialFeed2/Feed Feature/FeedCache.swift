//
//  FeedCache.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/18/25.
//

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
