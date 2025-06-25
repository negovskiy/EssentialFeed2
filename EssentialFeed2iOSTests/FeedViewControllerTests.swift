//
//  FeedViewControllerTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/25/25.
//

import XCTest
import UIKit
import EssentialFeed2
import EssentialFeed2iOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected loader to not have been called yet")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected loader to have been called once")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected loader to have been called twice")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected loader to have been called thrice")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator to be visible")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected loading indicator to be hidden")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator to be visible")
    
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected loading indicator to be hidden")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(string: "http://any-url.com")!
    ) -> FeedImage {
        .init(
            id: UUID(),
            description: description,
            location: location,
            url: url
        )
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageView() == feed.count else {
            return XCTFail(
                "Expected \(feed.count) rendered feed image view(s), but got \(sut.numberOfRenderedFeedImageView()) instead",
                file: file,
                line: line
            )
        }
        
        for (index, image) in feed.enumerated() {
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail(
                "Expected to render a FeedImageCell, but \(String(describing: view)) was rendered.",
                file: file,
                line: line
            )
        }
        
        let shouldLocationBeVisible = image.location != nil
        
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected isShowingLocation to be \(shouldLocationBeVisible)",
            file: file,
            line: line
        )
    
        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected to show the correct location, but \(String(describing: cell.locationText)) was shown.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            "Expected to show the correct description, but \(String(describing: cell.descriptionText)) was shown.",
            file: file,
            line: line
        )
    }
    
    class LoaderSpy: FeedLoader {
        
        var loadCallCount: Int {
            completions.count
        }
        
        private var completions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }
    }
    
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fakeRefreshControl
    }
    
    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageView() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    private var feedImagesSection: Int {
        0
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}
