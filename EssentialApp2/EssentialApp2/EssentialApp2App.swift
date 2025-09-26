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
#if DEBUG
        let (feedLoader, imageLoader) = DebuggingDataLoaderFactory().makeLoaders()
#else
        let (feedLoader, imageLoader) = DataLoaderFactory().makeLoaders()
#endif
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: feedLoader,
            imageLoader: imageLoader
        )
        return UINavigationController(rootViewController: feedViewController)
    }
}
