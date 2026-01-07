//
//  FeedEndpoint.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 11/8/25.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            baseURL.appending(component: "/v1/image/\(id)/comments")
        }
    }
}
