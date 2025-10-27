//
//  CommentsUIIntegrationTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 10/27/25.
//

import XCTest
import UIKit
import Combine
import EssentialFeed2
import EssentialFeed2iOS
import EssentialApp2

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected loader to not have been called yet")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected loader to have been called once")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected loader to have been called twice")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected loader to have been called thrice")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator to be visible")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected loading indicator to be hidden")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator to be visible")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected loading indicator to be hidden")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedListReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedListReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
        
        RunLoop.main.run(until: .now + 1)
    }
    
    func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        
        sut.simulateUserInitiatedListReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, errorMessage)
        
        sut.simulateUserInitiatedListReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    override func test_tap_hidesErrorView() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, errorMessage)
        
        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }
    func test_loadCommentsCompletion_dispatchFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(with: [])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeComment(
        message: String = "any message",
        username: String = "any username"
    ) -> ImageComment {
        .init(
            id: UUID(),
            message: message,
            createdAt: .now,
            username: username
        )
    }
    
    private func assertThat(
        _ sut: ListViewController,
        isRendering comments: [ImageComment],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let commentsCount = sut.numberOfRenderedComments()
        XCTAssertEqual(commentsCount, comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(
                sut.commentMessage(at: index),
                comment.message,
                "Message at \(index)",
                file: file,
                line: line
            )
            
            XCTAssertEqual(
                sut.commentDate(at: index),
                comment.date,
                "Date at \(index)",
                file: file,
                line: line
            )
            
            XCTAssertEqual(
                sut.commentUsername(at: index),
                comment.username,
                "Username at \(index)",
                file: file,
                line: line
            )
        }
    }
    
    private class LoaderSpy {
        
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        private var requests: [PassthroughSubject<[ImageComment], Error>] = []
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comment: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comment)
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: (.failure(error)))
        }
    }
}
