//
//  UIControler+TestHelpers.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/29/25.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
