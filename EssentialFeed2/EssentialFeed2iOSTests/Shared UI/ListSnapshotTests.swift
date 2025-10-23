//
//  ListSnapshotTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import XCTest
@testable import EssentialFeed2
import EssentialFeed2iOS

final class ListSnapshotTests: XCTestCase {
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti line\n error message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        trackForMemoryLeaks(controller, file: file, line: line)
        return controller
    }
    
    private func emptyList() -> [CellController] {
        []
    }
}
