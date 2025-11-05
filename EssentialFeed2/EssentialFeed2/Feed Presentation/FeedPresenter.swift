//
//  FeedPresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

import Foundation

public class FeedPresenter {
    public static var title: String {
        String(
            localized: "FEED_VIEW_TITLE",
            table: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    private var feedLoadError: String {
        String(
            localized: "GENERIC_CONNECTION_ERROR",
            table: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
}
