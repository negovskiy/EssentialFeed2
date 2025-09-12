//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/30/25.
//

import UIKit
import EssentialFeed2

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    var presenter: FeedPresenter?
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoadingFeed(feed)
            case let .failure(error):
                presenter?.didFinishLoadingFeedWithError(error)
            }
        }
    }
}
