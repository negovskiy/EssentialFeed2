//
//  ImageCommentsMapper.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
        
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            isOk(response: response),
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }
    
    private static func isOk(response: HTTPURLResponse) -> Bool {
        (200..<300).contains(response.statusCode)
    }
}
