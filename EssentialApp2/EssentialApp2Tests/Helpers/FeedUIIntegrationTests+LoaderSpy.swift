//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import Foundation
import Combine
import EssentialFeed2
import EssentialFeed2iOS

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        private var feedRequests: [PassthroughSubject<[FeedImage], Error>] = []
        
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(feed)
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: (.failure(error)))
        }
        
        // MARK: - ImageDataLoader
        
        private struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        var loadedImageURLs: [URL] {
            imageRequests.map(\.url)
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set)var cancelledImageURLs: [URL] = []
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            
            return FeedImageDataLoaderTaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}
