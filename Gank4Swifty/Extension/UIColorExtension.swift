//
//  UIColorExtension.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/13/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 256
        let green = CGFloat((hex & 0x00FF00) >> 8) / 256
        let blue = CGFloat((hex & 0x0000FF)) / 256
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
