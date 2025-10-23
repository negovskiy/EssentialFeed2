//
//  SnapshotConfiguration.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import UIKit

struct SnapshotConfiguration {
    // https://developer.apple.com/design/human-interface-guidelines/layout
    
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone17ProMax(
        _ style: UIUserInterfaceStyle,
        contentSize: UIContentSizeCategory = .medium
    ) -> Self {
        let traitCollection = UITraitCollection { mutableTraits in
            mutableTraits.userInterfaceStyle = style
            mutableTraits.forceTouchCapability = .available
            mutableTraits.layoutDirection = .leftToRight
            mutableTraits.preferredContentSizeCategory = contentSize
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
