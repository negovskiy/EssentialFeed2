//
//  FeedViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/27/25.
//

import Foundation
import EssentialFeed2

final class FeedViewModel {
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading = false {
        didSet { onChange?(self) }
    }
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            
            self?.isLoading = false
        }
    }
}
