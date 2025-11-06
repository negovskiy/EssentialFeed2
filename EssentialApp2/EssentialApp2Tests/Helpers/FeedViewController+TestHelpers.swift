//
//  FeedViewController+TestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import UIKit
import EssentialFeed2iOS

extension ListViewController {
    func simulateUserInitiatedListReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func cell(for row: Int, in section: Int) -> UITableViewCell? {
        guard section < tableView.numberOfSections else {
            return nil
        }
        
        guard row < tableView.numberOfRows(inSection: section) else {
            return nil
        }
        
        let indexPath = IndexPath(row: row, section: section)
        return tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
}

extension ListViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        feedImageView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else {
            return
        }
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    var isShowingLoadMoreFeedIndicator: Bool {
        loadMoreFeedCell()?.isLoading == true
    }
    
    var loadMoreFeedErrorMessage: String? {
        loadMoreFeedCell()?.message
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(for: 0, in: feedLoadMoreSection) as? LoadMoreCell
    }
    
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewNotVisible(at: row)
        
        let index = IndexPath(row: row, section: feedImagesSection)
        tableView.delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        guard tableView.numberOfSections > feedImagesSection else {
            return 0
        }
        
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(for: row, in: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        0
    }
    
    private var feedLoadMoreSection: Int {
        1
    }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        guard tableView.numberOfSections > commentsSection else {
            return 0
        }
        
        return tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private var commentsSection: Int {
        0
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        cell(for: row, in: commentsSection) as? ImageCommentCell
    }
}

extension ListViewController {
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
