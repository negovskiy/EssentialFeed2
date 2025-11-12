//
//  FeedImageDataStore.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias RetrievalResult = Swift.Result<Data?, Error>
    
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataFor url: URL) throws -> Data?
    
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    @available(*, deprecated)
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        var result: InsertionResult?
        
        let group = DispatchGroup()
        group.enter()
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        
        try result?.get()
    }
    
    func retrieve(dataFor url: URL) throws -> Data? {
        var result: RetrievalResult?
        
        let group = DispatchGroup()
        group.enter()
        retrieve(dataFor: url) {
            result = $0
            group.leave()
        }
        group.wait()
        
        return try result?.get()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
