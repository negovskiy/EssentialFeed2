//
//  HTTPClient.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 4/24/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
