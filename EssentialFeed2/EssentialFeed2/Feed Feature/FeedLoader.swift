//
//  FeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/18/25.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
