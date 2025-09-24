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
            rootView
                .ignoresSafeArea()
        }
    }
    
    var rootView: some View {
        RootViewControllerWrapper()
    }
}

private struct RootViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
#if DEBUG
        let (feedLoader, imageLoader) = DebuggingDataLoaderFactory().makeLoaders()
#else
        let (feedLoader, imageLoader) = DataLoaderFactory().makeLoaders()
#endif
        
        return FeedUIComposer.feedComposedWith(
            feedLoader: feedLoader,
            imageLoader: imageLoader
        )
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
