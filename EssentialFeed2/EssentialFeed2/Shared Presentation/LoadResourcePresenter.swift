//
//  LoadResourcePresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/10/25.
//


import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    
    private let loadingView: FeedLoadingView
    private let resourceView: ResourceView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    private var feedLoadError: String {
        String(
            localized: "FEED_VIEW_CONNECTION_ERROR",
            table: "Feed",
            bundle: Bundle(for: LoadResourcePresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(loadingView: FeedLoadingView, resourceView: ResourceView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(_ resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeedWithError(_ error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
