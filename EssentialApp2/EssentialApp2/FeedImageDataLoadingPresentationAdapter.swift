//
//  FeedImageDataLoadingPresentationAdapter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/30/25.
//

import Foundation
import Combine
import EssentialFeed2
import EssentialFeed2iOS

final class FeedImageDataLoadingPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: AnyCancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(withError: error, for: model)
                }
            }, receiveValue: { [weak self] value in
                self?.presenter?.didFinishLoadingImageData(with: value, for: model)
            })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
