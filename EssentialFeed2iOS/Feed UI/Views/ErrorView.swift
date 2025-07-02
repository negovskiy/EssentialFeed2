//
//  ErrorView.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//


import UIKit

public final class ErrorView: UIView {
    
    @IBOutlet private var label: UILabel!
    
    @IBAction private func tapAction() { hideMessageAnimated() }
    
    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
        alpha = 0
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
        label.text = message
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.3,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.label.text = nil }
            }
        )
    }
}
