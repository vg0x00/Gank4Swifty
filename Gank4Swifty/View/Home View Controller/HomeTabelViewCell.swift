//
//  HomeTabelViewCell.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/7/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class HomeTabelViewCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    func config(withModelPresentable model: ModelPresentable) {
        descLabel.text = model.title
        authorLabel.text = model.author
        categoryLabel.text = model.type
        dateLabel.text = model.date
    }
}
