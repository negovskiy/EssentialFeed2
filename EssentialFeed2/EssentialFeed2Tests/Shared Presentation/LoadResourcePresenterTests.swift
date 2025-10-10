//
//  LoadResourcePresenterTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/10/25.
//


import XCTest
import EssentialFeed2

class LoadResourcePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages initially")
    }
    
    func test_didStartLoading_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(
            view.messages,
            [.display(errorMessage: .none), .display(isLoading: true)]
        )
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let resource = "a resource"
        let (sut, view) = makeSUT { resourceToMap in
            resourceToMap + "view model"
        }
        
        sut.didFinishLoading(resource)
        
        XCTAssertEqual(
            view.messages,
            [.display(resourceViewModel: resource + "view model"), .display(isLoading: false)]
        )
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeedWithError(anyNSError())
        
        XCTAssertEqual(
            view.messages,
            [
                .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
                .display(isLoading: false)
            ]
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        mapper: @escaping LoadResourcePresenter.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: LoadResourcePresenter,
        view: ViewSpy
    ) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(loadingView: view, resourceView: view, errorView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func localized( _ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = String(localized: String.LocalizationValue(key), table: table, bundle: bundle)
        
        if key == value {
            XCTFail(
                "Missing localized string for \(key)",
                file: file,
                line: line
            )
        }
        
        return value
    }
    
    private class ViewSpy: FeedLoadingView, ResourceView, FeedErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
