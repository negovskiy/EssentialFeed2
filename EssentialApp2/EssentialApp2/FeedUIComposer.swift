//
//  FeedUIComposer.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/26/25.
//

import Combine
import UIKit
import EssentialFeed2
import EssentialFeed2iOS

public enum FeedUIComposer {
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController {
        let presentationAdapter =
        LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)
        let feedController = makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        
        return feedController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController { coder in
            ListViewController(coder: coder)
        }!
        feedController.title = title
        return feedController
    }
}
