//
//  FeedPresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/27/25.
//

import EssentialFeed2

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
        
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            
            self?.loadingView?.display(FeedLoadingViewModel(isLoading:  false))
        }
    }
}
