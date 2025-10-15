//
//  FeedImagePresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/23/25.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        .init(description: image.description, location: image.location)
    }
}
