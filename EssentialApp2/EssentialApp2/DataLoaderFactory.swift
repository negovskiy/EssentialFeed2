//
//  DataLoaderFactory.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/23/25.
//

import CoreData
import EssentialFeed2

class DataLoaderFactory {
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    func makeLoaders() -> (feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteLoader(
            url: remoteURL,
            client: remoteClient,
            mapper: FeedItemsMapper.map
        )
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(currentDate: Date.init, store: localStore)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        let feedLoader = FeedLoaderWithFallbackComposite(
            primary: FeedLoaderCacheDecorator(
                decoratee: remoteFeedLoader,
                cache: localFeedLoader
            ),
            fallback: localFeedLoader
        )
        
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(
            primary: localImageLoader,
            fallback: FeedImageDataLoaderCacheDecorator(
                decoratee: remoteImageLoader,
                cache: localImageLoader
            )
        )
        
        return (feedLoader, imageLoader)
    }
    
    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

extension RemoteLoader: @retroactive FeedLoader where Resource == [FeedImage] {}
