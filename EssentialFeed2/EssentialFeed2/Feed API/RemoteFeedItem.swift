//
//  RemoteFeedItem.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 5/10/25.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
