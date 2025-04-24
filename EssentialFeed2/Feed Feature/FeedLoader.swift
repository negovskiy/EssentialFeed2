//
//  FeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/18/25.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
