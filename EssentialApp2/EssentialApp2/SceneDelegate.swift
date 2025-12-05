//
//  SceneDelegate.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 11/8/25.
//

import Combine
import CoreData
import os
import UIKit
import EssentialFeed2

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var scheduler: AnyDispatchQueueScheduler = {
        if let store = store as? CoreDataFeedStore {
            return .scheduler(for: store)
        }
        
        return DispatchQueue(
            label: "com.negovskiy.EssentialApp2.infra.queue",
            qos: .userInitiated,
            attributes: .concurrent
        ).eraseToAnyScheduler()
    }()
    
    private let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var logger = Logger(
        subsystem: "com.negovskiy.EssentialApp2",
        category: "main"
    )
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore & StoreScheduler & Sendable = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreDataFeedStore: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreDataFeedStore: \(error.localizedDescription)")
            return InMemoryFeedStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(currentDate: Date.init, store: store)
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithFallbackToLocal,
            imageLoader: loadLocalImageWithRemoteFallback,
            selection: showComments))
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore & StoreScheduler & Sendable,
    ) {
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
        scheduler.schedule { [localFeedLoader, logger] in
            do {
                try localFeedLoader.validateCache()
            } catch {
                logger.error("Failed to validate feed cache: \(error.localizedDescription)")
            }
        }
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    private func makeRemoteFeedLoaderWithFallbackToLocal() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .receive(on: scheduler)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage? = nil) -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader(after: last)
            .zip(localFeedLoader.loadPublisher())
            .map { (newItems, cachedItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .receive(on: scheduler)
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoader(after last: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        httpClient
            .getPublisher(url: FeedEndpoint.get(after: last).url(from: remoteURL))
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(_ items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items, lastItem: items.last)
    }
    
    private func makePage(_ items: [FeedImage], lastItem: FeedImage?) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMorePublisher: lastItem.map { last in
                { self.makeRemoteLoadMoreLoader(last: last) }
            })
    }
    
    private func loadLocalImageWithRemoteFallback(for url: URL) async throws -> Data {
        do {
            return try await loadLocalImage(url: url)
        } catch {
            return try await loadAndCacheRemoteImage(url: url)
        }
    }
    
    private func loadLocalImage(url: URL) async throws -> Data {
        try await store.schedule { [store] in
            let localImageLoader = LocalFeedImageDataLoader(store: store)
            let imageData = try localImageLoader.loadImageData(from: url)
            return imageData
        }
    }
    
    private func loadAndCacheRemoteImage(url: URL) async throws -> Data {
        let (data, response) = try await httpClient.get(from: url)
        let imageData = try FeedImageDataMapper.map(data, response)
        
        await store.schedule { [store] in
            let localImageLoader = LocalFeedImageDataLoader(store: store)
            try? localImageLoader.saveImageData(data, for: url)
        }
        
        return imageData
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

protocol StoreScheduler {
    @MainActor
    func schedule<T>(_ action:  @escaping @Sendable () throws -> T) async rethrows -> T
}

extension CoreDataFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
        if contextQueue == .main {
            return try action()
        } else {
            return try await perform(action)
        }
    }
}

extension InMemoryFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @escaping () throws -> T) async rethrows -> T {
        try action()
    }
}
