//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import XCTest
@testable import EssentialFeed2
import EssentialFeed2iOS

final class ImageCommentsSnapshotTests: XCTestCase {
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "IMAGE_COMMENTS_dark")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        trackForMemoryLeaks(controller, file: file, line: line)
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map {
            CellController($0)
        }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long username long long long "
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. ",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Short text",
                    date: "10 hour ago",
                    username: "a."
                )
            )
        ]
    }
}
