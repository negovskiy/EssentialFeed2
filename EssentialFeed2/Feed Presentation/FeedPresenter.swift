//
//  FeedPresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        .init(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    private var feedLoadError: String {
        String(
            localized: "FEED_VIEW_CONNECTION_ERROR",
            table: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
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
