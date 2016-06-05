//
//  BackgroundViewCell.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 16/6/5.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

let kCellSelectedColor = UIColor(red:3 / 255.0, green:169 / 255.0, blue:244 / 255.0, alpha:1)
let kBackgroundViewCellID = "BackgroundViewCell"

class BackgroundViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = kCellSelectedColor
    }
}
