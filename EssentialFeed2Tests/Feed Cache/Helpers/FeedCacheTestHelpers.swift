//
//  FeedCacheTestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/16/25.
//

import Foundation
import EssentialFeed2

func uniqueImage() -> FeedImage {
    .init(
        id: UUID(),
        description: "any",
        location: "any",
        url: anyURL()
    )
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map {
        LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )
    }
    
    return (models, local)
}

extension Date {
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }
    
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self.addingTimeInterval(seconds)
    }
}
