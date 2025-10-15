//
//  ImageCommentsPresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/15/25.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        String(
            localized: "IMAGE_COMMENTS_VIEW_TITLE",
            table: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the feed view"
        )
    }
}
