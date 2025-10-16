//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/30/25.
//

import Combine
import EssentialFeed2
import EssentialFeed2iOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: AnyCancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingWithError(error)
                }
            }, receiveValue: { [weak self] result in
                self?.presenter?.didFinishLoading(result)
            })
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
