//
//  LoadResourcePresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/10/25.
//


import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let loadingView: FeedLoadingView
    private let resourceView: View
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    private var feedLoadError: String {
        String(
            localized: "GENERIC_CONNECTION_ERROR",
            table: "Feed",
            bundle: Bundle(for: LoadResourcePresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(loadingView: FeedLoadingView, resourceView: View, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(_ resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingWithError(_ error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
