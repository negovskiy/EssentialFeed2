//
//  LoadResourcePresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/10/25.
//


import Foundation

public class LoadResourcePresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    private var feedLoadError: String {
        String(
            localized: "FEED_VIEW_CONNECTION_ERROR",
            table: "Feed",
            bundle: Bundle(for: LoadResourcePresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(_ feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeedWithError(_ error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
