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
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        public init(_ completion: ((FeedImageDataLoader.Result) -> Void)? = nil) {
            self.completion = completion
        }
        
        public func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        public func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping ((LoadResult) -> Void)
    ) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        task.complete(with: Swift.Result {
            try store.retrieve(dataFor: url)
        }
            .mapError { _ in LoadError.failed }
            .flatMap { data in
                data.map { .success($0) } ?? .failure(LoadError.notFound)
            })
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public typealias SaveResult = FeedImageDataCache.SaveResult
    
    public func saveImageData(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        completion(
            SaveResult(catching: {
                try store.insert(data, for: url)
            })
            .mapError { _ in SaveError.failed }
        )
    }
}
