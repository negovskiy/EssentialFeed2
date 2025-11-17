//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/9/25.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataFor: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        
        throw LoadError.notFound
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Swift.Error {
        case failed
    }
        
    public func saveImageData(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}
