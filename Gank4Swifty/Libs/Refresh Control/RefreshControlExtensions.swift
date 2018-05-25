//
//  Extensions.swift
//  tableRefresh
//
//  Created by vg0x00 on 5/21/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

enum RefreshControlType {
    case header
    case footer
}

extension UIScrollView {

    func addFooterRefreshControl(backgroundColor: UIColor = UIColor(hex: 0xA6A6A6), delegate: RefreshControlDelegate) {
        let footerRefreshControl = RefreshControlFooter()
        footerRefreshControl.delegate = delegate
        footerRefreshControl.backgroundColor = backgroundColor
        insertSubview(footerRefreshControl, at: 0)
    }

    func addHeaderRefreshControl(backgroundColor: UIColor = UIColor(hex: 0xA6A6A6), delegate: RefreshControlDelegate) {
        let headerRefreshControl = RefreshControlHeader()
        headerRefreshControl.delegate = delegate
        headerRefreshControl.backgroundColor = backgroundColor
        insertSubview(headerRefreshControl, at: 0)
    }
}

