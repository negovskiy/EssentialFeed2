//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import Foundation
import XCTest
import EssentialFeed2

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        typealias ResourceViewModel = Any
        func display(_ viewModel: ResourceViewModel) {}
    }
    
    var errorMessage: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}
