//
//  FeedViewAdapter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/30/25.
//

import UIKit
import EssentialFeed2
import EssentialFeed2iOS

final class FeedViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: ListViewController?, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(
            viewModel.feed.map { model in
                let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                    imageLoader(model.url)
                })
                
                let view = FeedImageCellController(
                    viewModel: FeedImagePresenter.map(model),
                    delegate: adapter
                )
                
                adapter.presenter = LoadResourcePresenter(
                    loadingView: WeakRefVirtualProxy(view),
                    resourceView: WeakRefVirtualProxy(view),
                    errorView: WeakRefVirtualProxy(view),
                    mapper: { data in
                        guard let image = UIImage.init(data: data) else {
                            throw InvalidImageData()
                        }
                        
                        return image
                    }
                )
                
                return view
            })
    }
}
    
private struct InvalidImageData: Error {}
