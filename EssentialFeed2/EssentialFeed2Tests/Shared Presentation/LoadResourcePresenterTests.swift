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
    
    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
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
    
    func test_didFinishLoadingWithMapperError_displaysLocalizedErrorAndStopsLoading() {
        let resource = "a resource"
        let (sut, view) = makeSUT { resourceToMap in
            throw anyNSError()
        }
        
        sut.didFinishLoading(resource)
        
        XCTAssertEqual(
            view.messages,
            [
                .display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
                .display(isLoading: false)
            ]
        )
    }
    
    func test_didFinishLoadingWithError_displaysLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingWithError(anyNSError())
        
        XCTAssertEqual(
            view.messages,
            [
                .display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
                .display(isLoading: false)
            ]
        )
    }
    
    // MARK: - Helpers
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: SUT,
        view: ViewSpy
    ) {
        let view = ViewSpy()
        let sut = SUT(loadingView: view, resourceView: view, errorView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func localized( _ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: SUT.self)
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
    
    private class ViewSpy: ResourceLoadingView, ResourceView, ResourceErrorView {
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}
