//
//  CalendarCellViewCollectionViewCell.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/6/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class CalendarCellViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        let buttonWidth = button.bounds.width
        button.layer.cornerRadius = buttonWidth / 2
        button.layer.masksToBounds = true
    }
}
