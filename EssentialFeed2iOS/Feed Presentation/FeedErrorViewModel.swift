//
//  FeedErrorViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        .init(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}
