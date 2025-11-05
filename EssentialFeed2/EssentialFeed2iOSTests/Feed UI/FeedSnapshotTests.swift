//
//  FeedSnapshotTests.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 9/26/25.
//

import XCTest
@testable import EssentialFeed2
import EssentialFeed2iOS

class FeedSnapshotTests: XCTestCase {
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(
            snapshot: sut.snapshot(for: .iPhone17ProMax(.light)),
            named: "FEED_WITH_CONTENT_light"
        )
        
        assert(
            snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)),
            named: "FEED_WITH_CONTENT_dark"
        )
        
        assert(
            snapshot: sut.snapshot(
                for: .iPhone17ProMax(.light, contentSize: .extraExtraExtraLarge)
            ),
            named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge"
        )
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(
            snapshot: sut.snapshot(for: .iPhone17ProMax(.light)),
            named: "FEED_WITH_FAILED_IMAGE_LOADING_light"
        )
        
        assert(
            snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)),
            named: "FEED_WITH_FAILED_IMAGE_LOADING_dark"
        )
        
        assert(
            snapshot: sut.snapshot(
                for: .iPhone17ProMax(.light, contentSize: .extraExtraExtraLarge)
            ),
            named: "FEED_WITH_FAILED_IMAGE_LOADING_light_extraExtraExtraLarge"
        )
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
    
    private func feedWithContent() -> [ImageStub] {
        [
            .init(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            .init(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        [
            .init(description: "", location: "Location", image: nil),
            .init(description: "", location: "Location", image: nil)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        self.display(stubs.map {
            let controller = FeedImageCellController(
                viewModel: $0.viewModel,
                delegate: $0,
                selection: {}
            )
            $0.controller = controller
            return CellController(UUID(), controller)
        })
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = .init(description: description, location: location)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        
        if let image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {}
}
