//
//  DataModelItem.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/5/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

struct DataModelItem: ModelPresentable {
  var model: DataModel
  var title: String
  var date: String
  var url: URL?
  var images: [URL?]
  var author: String
  var type: String

  init(withModel model: DataModel) {
    self.model = model
    self.title = model.desc
    self.date = DateUtil.transformDateString(withDateString: model.publishedAt, outFormat: "yyyy-MM-dd")
    self.url = URL(string: model.url)
    self.images = model.images.map{ URL(string: $0) }
    self.author = model.who.isEmpty ? "void": model.who
    self.type = model.type
  }
}
