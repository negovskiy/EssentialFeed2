//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Andrey Negovskiy on 6/21/25.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet weak var locationContainer: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var feedImageContainer: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
}

extension FeedImageCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
        feedImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
        feedImageContainer.startShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.feedImageView.alpha = 1
            },
            completion: { completed in
                if completed {
                    self.feedImageContainer.stopShimmering()
                }
            }
        )
    }
}

private extension UIView {

    func startShimmering() {
        layer.mask = ShimmeringLayer(size: bounds.size)
    }

    func stopShimmering() {
        layer.mask = nil
    }
    
    private class ShimmeringLayer: CAGradientLayer {
        private var observer: Any?
        
        convenience init(size: CGSize) {
            self.init()
            
            let white = UIColor.white.cgColor
            let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
            
            colors = [alpha, white, alpha]
            startPoint = CGPoint(x: 0.0, y: 0.4)
            endPoint = CGPoint(x: 1.0, y: 0.6)
            locations = [0.4, 0.5, 0.6]
            frame = CGRect(x: -size.width, y: 0, width: size.width*3, height: size.height)
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
            animation.fromValue = [0.0, 0.1, 0.2]
            animation.toValue = [0.8, 0.9, 1.0]
            animation.duration = 1.25
            animation.repeatCount = .infinity
            add(animation, forKey: "shimmer")
            
            observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
                self?.add(animation, forKey: "shimmer")
            }
        }
    }
}
