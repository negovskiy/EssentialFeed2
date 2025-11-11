//
//  FeedEndpoint.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 11/8/25.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)
    
    public func url(from baseURL: URL) -> URL {
        switch self {
        case let .get(image):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
            ].compactMap { $0 }
            return components.url!
        }
    }
}
