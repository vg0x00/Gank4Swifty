//
//  ModelPresentableProtocol.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/5/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

protocol ModelPresentable {
  var title: String { get }
  var date: String { get }
  var url: URL? { get }
  var images: [URL?] { get }
  var author: String { get }
  var type: String { get }
}
