//
//  FeedImageCellController.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/26/25.
//


import UIKit
import EssentialFeed2

final class FeedImageCellController {
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let cell, let self else { return }
            
            task = imageLoader.loadImageData(from: model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                
                cell?.feedImageRetryButton.isHidden = image != nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        loadImage()
        cell.onRetry = loadImage
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
