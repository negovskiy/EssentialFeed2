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
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti line\n error message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "FEED_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone17ProMax(.dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
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
    func snapshot(for configuration: SnapshotConfiguration) -> Data {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17ProMax(.light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: .init(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.overrideUserInterfaceStyle = configuration.traitCollection.userInterfaceStyle
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    func traitCollection() -> UITraitCollection {
        configuration.traitCollection
    }
    
    func snapshot() -> Data {
        let renderer = UIGraphicsImageRenderer(
            bounds: bounds,
            format: .init(for: configuration.traitCollection)
        )
        return renderer.pngData { actions in
            layer.render(in: actions.cgContext)
        }
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        self.display(stubs.map {
            let controller = FeedImageCellController(viewModel: $0.viewModel, delegate: $0)
            $0.controller = controller
            return controller
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

struct SnapshotConfiguration {
    // https://developer.apple.com/design/human-interface-guidelines/layout
    
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone17ProMax(_ style: UIUserInterfaceStyle) -> Self {
        let traitCollection = UITraitCollection { mutableTraits in
            mutableTraits.userInterfaceStyle = style
            mutableTraits.forceTouchCapability = .available
            mutableTraits.layoutDirection = .leftToRight
            mutableTraits.preferredContentSizeCategory = .medium
            mutableTraits.userInterfaceIdiom = .phone
            mutableTraits.horizontalSizeClass = .compact
            mutableTraits.verticalSizeClass = .regular
            mutableTraits.displayScale = 3
            mutableTraits.displayGamut = .P3
        }

        return .init(
            size: .init(width: 440, height: 956),
            safeAreaInsets: .init(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: .init(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: traitCollection
        )
    }
}
