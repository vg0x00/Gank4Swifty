//
//  UserCollectionHeader.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/22/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class UserCollectionHeader: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleIcon: UIImageView! {
        didSet {
            titleIcon.tintColor = UIColor(displayP3Red: 255 / 255, green: 71 / 255, blue: 87 / 255, alpha: 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.backgroundColor = UIColor(displayP3Red: 244 / 255, green: 242 / 255, blue: 246 / 255, alpha: 1)
    }
}
