//
//  SceneDelegate.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 11/8/25.
//

import Combine
import CoreData
import OSLog
import UIKit
import EssentialFeed2

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(currentDate: Date.init, store: store)
    }()
    
    private lazy var localImageLoader: LocalFeedImageDataLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithFallbackToLocal,
            imageLoader: makeImageDataLoader,
            selection: showComments))
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    private func makeRemoteFeedLoaderWithFallbackToLocal() -> AnyPublisher<Paginated<FeedImage>, Error> {
        httpClient
            .getPublisher(url: FeedEndpoint.get().url(from: remoteURL))
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { [weak self] items in
                Paginated(
                    items: items,
                    loadMorePublisher: self?.makeRemoteLoadMoreLoader(for: items, last: items.last)
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(
        for items: [FeedImage],
        last: FeedImage? = nil
    ) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        last.map { lastItem in
            { [httpClient, remoteURL, localFeedLoader] in
                httpClient
                    .getPublisher(url: FeedEndpoint.get(after: lastItem).url(from: remoteURL))
                    .tryMap(FeedItemsMapper.map)
                    .map { [weak self] newItems in
                        let allItems = items + newItems
                        return Paginated(
                            items: allItems,
                            loadMorePublisher: self?.makeRemoteLoadMoreLoader(
                                for: allItems,
                                last: newItems.last
                            )
                        )
                    }
                    .caching(to: localFeedLoader)
            }
        }
    }
    
    private func makeImageDataLoader(for url: URL) -> FeedImageDataLoader.Publisher {
        localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback { [httpClient, localImageLoader] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }
    }
    
    private func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
    
    private func makeRemoteCommentsLoader(for image: FeedImage) -> () -> AnyPublisher<[ImageComment], Error> {
        { [httpClient, remoteURL] in
            httpClient
                .getPublisher(url: remoteURL.appending(path: "v1/image/\(image.id.uuidString)/comments"))
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    private func showComments(for image: FeedImage) {
        let comments = CommentsUIComposer.commentsComposedWith(
            commentsLoader: makeRemoteCommentsLoader(for: image)
        )
        navigationController.show(comments, sender: self)
    }
}
