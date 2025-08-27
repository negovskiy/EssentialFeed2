//
//  FeedItemsMapper.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/23/25.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
        
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.isOk,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}
