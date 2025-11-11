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
    private let currentFeed: [FeedImage: CellController]
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    
    private typealias ImageDataPresentationAdapter =
    LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter =
    LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(
        controller: ListViewController?,
        currentFeed: [FeedImage: CellController] = [:],
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.controller = controller
        self.currentFeed = currentFeed
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller else { return }
        
        var currentFeed = self.currentFeed
        let feed: [CellController] = viewModel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                }
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
            
            let controller = CellController(model, view)
            currentFeed[model] = controller
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(loadMore),
            resourceView: FeedViewAdapter(
                controller: controller,
                currentFeed: currentFeed,
                imageLoader: imageLoader,
                selection: selection
            ),
            errorView: WeakRefVirtualProxy(loadMore),
            mapper: { $0
            }
        )
        
        let loadMoreSection = [CellController(UUID(), loadMore)]
        
        controller.display(feed, loadMoreSection)
    }
}
    
private struct InvalidImageData: Error {}
