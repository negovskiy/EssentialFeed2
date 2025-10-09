//
//  FeedItemsMapper.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/23/25.
//

import Foundation

public final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        var models: [FeedImage] {
            items.map {
                .init(
                    id: $0.id,
                    description: $0.description,
                    location: $0.location,
                    url: $0.image
                )
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard
            response.isOk,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw Error.invalidData
        }
        
        return root.models
    }
}
