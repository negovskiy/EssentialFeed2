//
//  ListSnapshotTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import XCTest
import EssentialFeed2
import EssentialFeed2iOS

final class ListSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "EMPTY_FEED_dark")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        trackForMemoryLeaks(controller, file: file, line: line)
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
}
