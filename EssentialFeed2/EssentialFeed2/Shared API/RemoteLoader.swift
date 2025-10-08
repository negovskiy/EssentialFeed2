//
//  RemoteLoader.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/6/25.
//

import Foundation

public final class RemoteLoader<Resource> {
    
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (_ data: Data, _ response: HTTPURLResponse) throws -> Resource
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(map(data, response))
            case .failure:
                completion(.failure(RemoteLoader.Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        guard let items = try? mapper(data, response) else {
            return .failure(RemoteLoader.Error.invalidData)
        }
        
        return .success(items)
    }
}
