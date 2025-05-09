//
//  LocalFeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public final class LocalFeedLoader {
    
    private let currentDate: () -> Date
    private let store: FeedStore
    
    public init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }
    
    public func save(_ items: [FeedItem], _ completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
