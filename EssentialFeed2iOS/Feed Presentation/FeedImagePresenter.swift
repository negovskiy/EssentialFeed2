//
//  FeedImagePresenter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/27/25.
//

import Foundation
import EssentialFeed2

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(withError: InvalidImageDataError(), for: model)
        }
        
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(withError error: Error, for model: FeedImage) {
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
