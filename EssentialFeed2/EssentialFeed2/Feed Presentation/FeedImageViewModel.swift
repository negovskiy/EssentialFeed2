//
//  FeedImageViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/23/25.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
