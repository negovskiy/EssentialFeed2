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
        
        let feedLoader = MainQueueDispatchDecorator(decoratee: feedLoader)
        let imageLoader = MainQueueDispatchDecorator(decoratee: imageLoader)
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(feedController),
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        )
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController { coder in
            FeedViewController(coder: coder, delegate: delegate)
        }!
        feedController.title = title
        return feedController
    }
}
