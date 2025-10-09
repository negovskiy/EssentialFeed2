//
//  FeedImageDataMapper.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/9/25.
//

import Foundation

public final class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data {
        guard response.isOk, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}
