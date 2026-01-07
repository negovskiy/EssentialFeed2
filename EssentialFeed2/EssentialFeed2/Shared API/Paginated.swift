//
//  Paginated.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 11/5/25.
//

public struct Paginated<Item: Sendable>: Sendable {
    public let items: [Item]
    public let loadMore: (@Sendable () async throws -> Self)?
    
    public init(items: [Item], loadMore: (@Sendable () async throws -> Self)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
