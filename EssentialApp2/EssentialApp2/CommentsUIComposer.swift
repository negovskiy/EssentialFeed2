//
//  CommentsUIComposer.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 10/27/25.
//

import Combine
import UIKit
import EssentialFeed2
import EssentialFeed2iOS

public enum CommentsUIComposer {
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController {
        let presentationAdapter =
        LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: commentsLoader)
        let feedController = makeWith(title: ImageCommentsPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { _ in Empty<Data,Error>().eraseToAnyPublisher()}
            ),
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
