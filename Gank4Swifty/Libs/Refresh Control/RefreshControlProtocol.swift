//
//  RefreshControlProtocol.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/21/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

protocol RefreshControlAdaptable {
    var refreshControlContainer: UIScrollView? { get set }
    var state: RefreshControlState { get set }
    var type: RefreshControlType { get }

    // NOTE - update refresh control frame based on wether scroll
    //        content height bigger than scroll view bounds height
    func adjustRefreshControlFrame(scrollView: UIScrollView)

    // NOTE - update refresh control inner state based on scroll view content offset Y
    func adjustRefreshControlState(scrollView: UIScrollView)

    // NOTE - refresh action should fire or not
    func adjustRefreshControlPanState(sender: UIPanGestureRecognizer)

    func stopRefreshing()
}


protocol RefreshControlDelegate {
    func refreshControlDidRefresh(sender: RefreshControlAdaptable)
}


enum RefreshControlState {
    case normal
    case willRefreshing
    case refreshing
    //    case noMoreData
}
