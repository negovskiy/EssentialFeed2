//
//  FeedCache.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/18/25.
//

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ feed: [FeedImage], _ completion: @escaping (SaveResult) -> Void)
}
