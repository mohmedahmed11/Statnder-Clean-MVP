//
//  Extenstions.swift
//  Statnder-Clean-MVP
//
//  Created by Mohamed Ahmed on 12/27/22.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    @IBInspectable var cornerRadius: Double {
        get { return Double(self.layer.cornerRadius) }
        set { self.layer.cornerRadius = CGFloat(newValue) }
    }
    
    @IBInspectable var borderWidth: Double {
        get { return Double(self.layer.borderWidth) }
        set { self.layer.borderWidth = CGFloat(newValue) }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get { return UIColor(cgColor: self.layer.borderColor!) }
        set { self.layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get { return UIColor(cgColor: self.layer.shadowColor!) }
        set { self.layer.shadowColor = newValue?.cgColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return self.layer.shadowOpacity }
        set { self.layer.shadowOpacity = newValue }
    }
}

class CardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initailSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initailSetup()
    }
    
    private func initailSetup() {
        layer.shadowOffset = .zero
        layer.cornerRadius = 8
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        cornerRadius = 8
    }
}
