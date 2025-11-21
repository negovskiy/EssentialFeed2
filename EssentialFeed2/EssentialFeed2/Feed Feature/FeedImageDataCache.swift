//
//  FeedImageDataCache.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import Foundation

public protocol FeedImageDataCache {
    func saveImageData(_ data: Data, for url: URL) throws
}
