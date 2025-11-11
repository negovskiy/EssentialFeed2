//
//  ResourceErrorViewModel.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        .init(message: .none)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        .init(message: message)
    }
}
