//
//  FeedImageDataStoreSpy.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import XCTest
import EssentialFeed2

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    private(set) var receivedMessages: [Message] = []
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = (.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = (.success(()))
    }
    
    func retrieve(dataFor url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = (.success(data))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = (.failure(error))
    }
}
