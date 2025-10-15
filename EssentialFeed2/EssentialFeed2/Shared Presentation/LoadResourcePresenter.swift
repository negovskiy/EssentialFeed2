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
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    public static var loadError: String {
        String(
            localized: "GENERIC_CONNECTION_ERROR",
            table: "Shared",
            bundle: Bundle(for: LoadResourcePresenter.self),
            comment: "Error message displayed when we can't load resource from the server")
    }
    
    public init(loadingView: ResourceLoadingView, resourceView: View, errorView: ResourceErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(_ resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoadingWithError(error)
        }
    }
    
    public func didFinishLoadingWithError(_ error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
