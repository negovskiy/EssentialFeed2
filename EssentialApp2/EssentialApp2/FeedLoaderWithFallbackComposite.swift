//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/13/25.
//

import EssentialFeed2

public class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
