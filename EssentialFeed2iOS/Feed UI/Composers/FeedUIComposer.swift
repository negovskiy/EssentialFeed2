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
        
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
