//
//  DataLoaderFactory.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/23/25.
//

import CoreData
import EssentialFeed2

class DataLoaderFactory {
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var client: HTTPClient = {
        makeRemoteClient()
    }()
    
    func makeFeedLoader() -> FeedLoader.Publisher {
        let localFeedLoader = LocalFeedLoader(currentDate: Date.init, store: store)
        let remoteFeedLoader = RemoteLoader(url: remoteURL, client: client, mapper: FeedItemsMapper.map)
        
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    func makeImageDataLoader(for url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
    
    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

extension RemoteLoader: @retroactive FeedLoader where Resource == [FeedImage] {}
