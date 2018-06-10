//
//  UIViewExtension.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/13/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func startRotaing(duration: Double = 1.5) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}
