//
//  IBDesignableImageView.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/10/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
@IBDesignable

class IBDesignableImageView: UIImageView {
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}
