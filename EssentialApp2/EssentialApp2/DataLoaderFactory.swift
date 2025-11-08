//
//  DataLoaderFactory.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/23/25.
//

import CoreData
import Combine
import EssentialFeed2

class DataLoaderFactory {
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var client: HTTPClient = {
        makeRemoteClient()
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(currentDate: Date.init, store: store)
    }()
    
    private lazy var localImageLoader: LocalFeedImageDataLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    
    func makeRemoteFeedLoaderWithFallbackToLocal() -> AnyPublisher<Paginated<FeedImage>, Error> {
        client
            .getPublisher(url: FeedEndpoint.get().url(from: remoteURL))
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map {
                Paginated(items: $0)
            }
            .eraseToAnyPublisher()
    }
    
    func makeImageDataLoader(for url: URL) -> FeedImageDataLoader.Publisher {
        localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback { [client, localImageLoader] in
                client
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }
    }
    
    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
    
    func makeRemoteCommentsLoader(for image: FeedImage) -> () -> AnyPublisher<[ImageComment], Error> {
        { [client, remoteURL] in
            client
                .getPublisher(url: remoteURL.appending(path: "image/\(image.id.uuidString)/comments"))
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
}
