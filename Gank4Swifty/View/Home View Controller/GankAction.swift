//
//  GankAction.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/11/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class GankAction: UIActivity {
    var items: [Any]?
    var image: UIImage

    typealias addToCollectionHandler = () -> Void
    var userCollectionHandler: addToCollectionHandler?

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "com.vg0x00.gank4swifty")
    }

    override var activityTitle: String? {
        return "加入收藏"
    }

    override var activityImage: UIImage? {
        return self.image
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if item is URL {
                return true
            }
        }
        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        userCollectionHandler?()
    }
}
