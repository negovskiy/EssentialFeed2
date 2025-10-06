//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/3/25.
//

import Foundation

public final class RemoteImageCommentsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Error>
    
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
                completion(.failure(RemoteImageCommentsLoader.Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        guard let items = try? ImageCommentsMapper.map(data, response) else {
            return .failure(RemoteImageCommentsLoader.Error.invalidData)
        }
        
        return .success(items)
    }
}

private extension Array where Element == RemoteFeedItem {
    
    func toModels() -> [FeedImage] {
        map {
            .init(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.image
            )
        }
    }
}
