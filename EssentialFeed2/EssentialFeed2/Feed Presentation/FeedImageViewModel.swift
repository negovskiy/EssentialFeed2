//
//  FeedImageViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/23/25.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
