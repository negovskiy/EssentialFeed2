//
//  UIImageView+Animations.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 6/28/25.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
