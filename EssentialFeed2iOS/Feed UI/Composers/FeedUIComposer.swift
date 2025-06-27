//
//  FeedUIComposer.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/26/25.
//

import UIKit
import EssentialFeed2

public enum FeedUIComposer {
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        loader: FeedImageDataLoader
    ) -> ([FeedImage]) -> Void {
        { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = FeedImageViewModel(
                    model: model,
                    imageLoader: loader,
                    imageTransformer: UIImage.init
                )
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let viewModel = FeedImageViewModel(
                model: model,
                imageLoader: imageLoader,
                imageTransformer: UIImage.init
            )
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
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

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}
