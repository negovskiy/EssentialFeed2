//
//  ErrorView.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }
    
    var onHide: (() -> Void)?

    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        return AttributeContainer([
            .paragraphStyle: paragraphStyle,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ])
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        hideMessage()
    }
    
    private func configure() {
        hideMessage()
        backgroundColor = .errorBackgroundColor
        
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
                
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        configuration?.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.3,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            }
        )
    }
    
    private func hideMessage() {
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        
        alpha = 0
        
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
