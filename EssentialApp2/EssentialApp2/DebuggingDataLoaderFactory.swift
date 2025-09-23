//
//  DebuggingDataLoaderFactory.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/23/25.
//

#if DEBUG
import Foundation
import EssentialFeed2

class DebuggingDataLoaderFactory: DataLoaderFactory {
    override func makeLoaders() -> (feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        return super.makeLoaders()
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        
        return super.makeRemoteClient()
    }
}

private class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed2.HTTPClientTask {
        completion(.failure(NSError(domain: "domain", code: 0)))
        return Task()
    }
}
#endif
