//
//  FeedItem.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/18/25.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
