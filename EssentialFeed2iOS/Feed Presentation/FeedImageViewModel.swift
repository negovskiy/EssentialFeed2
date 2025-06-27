//
//  FeedImageViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/27/25.
//

public struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
