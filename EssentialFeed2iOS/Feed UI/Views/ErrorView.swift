//
//  ErrorView.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 7/2/25.
//


import UIKit

public final class ErrorView: UIView {
    
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
