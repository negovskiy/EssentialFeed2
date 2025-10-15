//
//  ImageCommentsPresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/15/25.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {
    public static var title: String {
        String(
            localized: "IMAGE_COMMENTS_VIEW_TITLE",
            table: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the feed view"
        )
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        
        return .init(comments: comments.map { comment in
                .init(
                    message: comment.message,
                    date: formatter.localizedString(for: comment.createdAt, relativeTo: .now),
                    username: comment.username
                )
        })
    }
}
