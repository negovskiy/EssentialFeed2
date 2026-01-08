//
//  CommentsUIIntegrationTests.swift
//  EssentialApp2
//
//  Created by Andrey Negovskiy on 10/27/25.
//

import XCTest
import UIKit
import EssentialFeed2
import EssentialFeed2iOS
import EssentialApp2

@MainActor
final class CommentsUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() async {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected loader to not have been called yet")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected loader to have been called once")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no requests until previous completes")
        
        await loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected loader to have been called twice")
        
        await loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected loader to have been called thrice")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() async {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be visible")
        
        await loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be visible")
        
        await loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be hidden")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() async {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        await loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedListReload()
        await loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        
        await loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedListReload()
        await loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        await loader.completeCommentsLoading(with: [comment], at: 0)
        
        sut.simulateUserInitiatedListReload()
        await loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() async {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        await loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, errorMessage)
        
        sut.simulateUserInitiatedListReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_tap_hidesErrorView() async {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        await loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, errorMessage)
        
        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_deinit_cancelsPendingCommentsLoading() async {
        let loader = LoaderSpy<Void, [ImageComment]>()
        var sut: ListViewController?
        
        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)
            sut?.simulateAppearance()
        }
        
        XCTAssertEqual(loader.cancelledCommentsRequestsCount, 0)
        
        sut = nil
        let result = try? await loader.result(at: 0)
    
        XCTAssertEqual(result, .cancelled)
        XCTAssertEqual(loader.cancelledCommentsRequestsCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: LoaderSpy<Void, [ImageComment]>) {
        let loader = LoaderSpy<Void, [ImageComment]>()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        addTeardownBlock { [weak loader] in
            try await loader?.cancelPendingRequests()
        }
        
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
}

private extension LoaderSpy where Param == Void, Resource == [ImageComment] {
    
    var loadCommentsCallCount: Int {
        requests.count
    }
    
    var cancelledCommentsRequestsCount: Int {
        requests.count { $0.result == .cancelled }
    }
    
    func loadComments() async throws -> [ImageComment] {
        try await load(())
    }
    
    func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) async {
        await complete(with: comments, at: index)
    }
    
    func completeCommentsLoadingWithError(at index: Int = 0) async {
        let error = NSError(domain: "an error", code: 0)
        await fail(with: error, at: index)
    }
}
