//
//  FeedImageDataLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/26/25.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
