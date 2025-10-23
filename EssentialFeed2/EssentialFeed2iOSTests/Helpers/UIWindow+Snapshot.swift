//
//  UIWindow+Snapshot.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> Data {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17ProMax(.light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: .init(origin: .zero, size: configuration.size))
        configuration.overrideTraitCollection(of: root)
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
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
