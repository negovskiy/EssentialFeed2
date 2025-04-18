//
//  FeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/18/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
