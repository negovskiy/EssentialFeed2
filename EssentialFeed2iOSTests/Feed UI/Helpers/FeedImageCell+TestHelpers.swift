//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import UIKit
import EssentialFeed2iOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}
