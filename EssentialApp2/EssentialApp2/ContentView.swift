//
//  ContentView.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 9/12/25.
//

import SwiftUI
import EssentialFeed2iOS

struct ContentView: View {
    var body: some View {
        FeedViewControllerWrapper()
            .ignoresSafeArea()
    }
}

private struct FeedViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FeedViewController {
        FeedViewController()
    }

    func updateUIViewController(_ uiViewController: FeedViewController, context: Context) {
    }
}

#Preview {
    ContentView()
}
