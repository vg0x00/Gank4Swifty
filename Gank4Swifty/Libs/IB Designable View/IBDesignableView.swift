//
//  IBDesignableView.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/13/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

@IBDesignable
class IBDesignableView: UIView {
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable
    var firstColor: UIColor = UIColor.clear {
        didSet {
            updateColorLayer()
        }
    }

    @IBInspectable
    var secondColor: UIColor = UIColor.clear {
        didSet {
            updateColorLayer()
        }
    }

    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    func updateColorLayer() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.startPoint = CGPoint.zero
        layer.endPoint = CGPoint(x: 0, y: 1)
    }
}
