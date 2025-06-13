//
//  FeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/18/25.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
