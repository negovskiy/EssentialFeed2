//
//  EssentialApp2App.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/12/25.
//

import SwiftUI
import EssentialFeed2iOS

@main
struct EssentialApp2App: App {
    var body: some Scene {
        WindowGroup {
            RootViewControllerWrapper()
                .ignoresSafeArea()
        }
    }
}

struct RootViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        makeRootViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeRootViewController() -> UIViewController {
        let factory: DataLoaderFactory
#if DEBUG
        factory = DebuggingDataLoaderFactory()
#else
        factory = DataLoaderFactory()
#endif
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: factory.makeFeedLoader,
            imageLoader: factory.makeImageDataLoader
        )
        return UINavigationController(rootViewController: feedViewController)
    }
}
