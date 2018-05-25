//
//  UIViewControllerExtension.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/13/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

extension UIViewController {
    func showHUD(_ type: HUDType = .processing) {
        let targetViewController =  HUDViewController.shared
        targetViewController.parentView = self.view
        targetViewController.type = type
        targetViewController.modalTransitionStyle = .crossDissolve
        targetViewController.modalPresentationStyle = .overCurrentContext

        present(targetViewController, animated: true, completion: nil)
    }

    func updateHUD(with type: HUDType) {
        let targetViewController =  HUDViewController.shared
        targetViewController.type = type
    }

    func hideHUD() {
        let targetViewController =  HUDViewController.shared
        targetViewController.hide(delay: 0)
    }
}
