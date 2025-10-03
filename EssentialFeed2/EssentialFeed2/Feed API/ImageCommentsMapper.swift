//
//  ImageCommentsMapper.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        private let items: [Item]
        
        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map {
                .init(
                    id: $0.id,
                    message: $0.message,
                    createdAt: $0.created_at,
                    username: $0.author.username
                )
            }
        }
    }
        
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard
            isOk(response: response),
            let root = try? decoder.decode(Root.self, from: data)
        else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.comments
    }
    
    private static func isOk(response: HTTPURLResponse) -> Bool {
        (200..<300).contains(response.statusCode)
    }
}
