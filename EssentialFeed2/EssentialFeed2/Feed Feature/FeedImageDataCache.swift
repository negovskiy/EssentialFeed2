//
//  FeedImageDataCache.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/19/25.
//

import Foundation

public protocol FeedImageDataCache<SaveError> {
    associatedtype SaveError: Error
    
    typealias SaveResult = Swift.Result<Void, SaveError>
    
    func saveImageData(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
