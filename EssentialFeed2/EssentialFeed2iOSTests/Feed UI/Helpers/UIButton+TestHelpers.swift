//
//  UIButton+TestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
