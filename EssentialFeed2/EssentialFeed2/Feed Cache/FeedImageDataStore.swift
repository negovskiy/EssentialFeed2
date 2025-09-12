//
//  FeedImageDataStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    typealias RetrievalResult = Swift.Result<Data?, Error>
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
}
