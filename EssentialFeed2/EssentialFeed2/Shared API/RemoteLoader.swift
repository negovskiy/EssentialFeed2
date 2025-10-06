//
//  RemoteLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/6/25.
//

import Foundation

public final class RemoteLoader: FeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, response))
            case .failure:
                completion(.failure(RemoteLoader.Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        guard let items = try? FeedItemsMapper.map(data, response) else {
            return .failure(RemoteLoader.Error.invalidData)
        }
        
        return .success(items)
    }
}
