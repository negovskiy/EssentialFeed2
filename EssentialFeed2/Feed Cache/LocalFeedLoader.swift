//
//  LocalFeedLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/9/25.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    private let currentDate: () -> Date
    private let store: FeedStore
    
    public init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }
    
    public func save(_ items: [FeedItem], _ completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        map {
            .init(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                imageURL: $0.imageURL
            )
        }
    }
}
