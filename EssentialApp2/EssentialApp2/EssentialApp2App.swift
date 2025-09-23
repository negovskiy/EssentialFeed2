//
//  EssentialApp2App.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/12/25.
//

import SwiftUI
import CoreData
import EssentialFeed2
import EssentialFeed2iOS

@main
struct EssentialApp2App: App {
    var body: some Scene {
        WindowGroup {
            FeedViewControllerWrapper()
                .ignoresSafeArea()
        }
    }
}

private struct FeedViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FeedViewController {
        let (feedLoader, imageLoader) = DataLoadersFactory.makeLoaders()
        return FeedUIComposer.feedComposedWith(
            feedLoader: feedLoader,
            imageLoader: imageLoader
        )
    }
    
    func updateUIViewController(_ uiViewController: FeedViewController, context: Context) {
    }
}

private class DataLoadersFactory {
    static func makeLoaders() -> (feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
        
#if DEBUG
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
#endif
        
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
    
    private static func makeRemoteClient() -> HTTPClient {
#if DEBUG
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
#endif
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

#if DEBUG
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
