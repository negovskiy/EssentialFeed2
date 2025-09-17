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
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = URLSessionHTTPClient(session: .shared)
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("Feed.sqlite")
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(currentDate: Date.init, store: localStore)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        let feedLoader = FeedLoaderWithFallbackComposite(
            primary: remoteFeedLoader,
            fallback: localFeedLoader
        )
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(
            primary: localImageLoader,
            fallback: remoteImageLoader
        )
        
        return FeedUIComposer.feedComposedWith(
            feedLoader: feedLoader,
            imageLoader: imageLoader
        )
    }

    func updateUIViewController(_ uiViewController: FeedViewController, context: Context) {
    }
}
