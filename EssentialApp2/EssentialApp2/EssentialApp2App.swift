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
