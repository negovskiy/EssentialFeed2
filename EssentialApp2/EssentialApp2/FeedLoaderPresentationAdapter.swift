//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/30/25.
//

import Combine
import EssentialFeed2
import EssentialFeed2iOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    var presenter: FeedPresenter?
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: AnyCancellable?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeedWithError(error)
                }
            }, receiveValue: { [weak self] result in
                self?.presenter?.didFinishLoadingFeed(result)
            })
    }
}
