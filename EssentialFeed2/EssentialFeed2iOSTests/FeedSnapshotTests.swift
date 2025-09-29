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
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti line\n error message"))
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        trackForMemoryLeaks(controller, file: file, line: line)
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
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
    
    private func makeSnapshotURL(for name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func record(snapshot data: Data, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(for: name, file: file)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try data.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func assert(
        snapshot expectedData: Data,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(for: name, file: file)
        
        guard let storedData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail(
                "Failed to read snapshot at url: \(snapshotURL). Use `record` first",
                file: file,
                line: line
            )
        }
        
        if storedData != expectedData {
            let temporarySnapshotURL = URL.temporaryDirectory
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? expectedData.write(to: temporarySnapshotURL)
            
            XCTFail(
                """
                New snapshot does not match the stored one. 
                New snapshot: \(temporarySnapshotURL)
                Stored One: \(snapshotURL)
                """,
                file: file,
                line: line
            )
        }
    }
}

extension UIViewController {
    func snapshot() -> Data {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.pngData { actions in
            view.layer.render(in: actions.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        self.display(stubs.map {
            let controller = FeedImageCellController(delegate: $0)
            $0.controller = controller
            return controller
        })
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = .init(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}
