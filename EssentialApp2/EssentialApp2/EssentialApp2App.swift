//
//  EssentialApp2App.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/12/25.
//

import SwiftUI
import EssentialFeed2
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
    private let navigationController = UINavigationController()
    
#if DEBUG
    private let factory = DebuggingDataLoaderFactory()
#else
    private let factory = DataLoaderFactory()
#endif
    
    func makeUIViewController(context: Context) -> UIViewController {
        makeRootViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeRootViewController() -> UIViewController {
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: factory.makeRemoteFeedLoaderWithFallbackToLocal,
            imageLoader: factory.makeImageDataLoader,
            selection: showComments
        )
        
        navigationController.viewControllers = [feedViewController]
        return navigationController
    }
    
    private func showComments(for image: FeedImage) {
        let comments = CommentsUIComposer.commentsComposedWith(
            commentsLoader: factory.makeRemoteCommentsLoader(for: image)
        )
        navigationController.pushViewController(comments, animated: true)
    }
}
