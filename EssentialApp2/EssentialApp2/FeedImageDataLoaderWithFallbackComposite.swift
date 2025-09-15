//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/15/25.
//

import Foundation
import EssentialFeed2

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    class Task: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (
            FeedImageDataLoader.Result
        ) -> Void
    ) -> any EssentialFeed2.FeedImageDataLoaderTask {
        let task = Task()
        task.wrapped = primary.loadImageData(from: url) { [weak self] primaryResult in
            switch primaryResult {
            case let .success(primaryData):
                completion(.success(primaryData))
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url) { fallbackResult in
                    switch fallbackResult {
                    case let .success(fallbackData):
                        completion(.success(fallbackData))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
        
        return task
    }
}
