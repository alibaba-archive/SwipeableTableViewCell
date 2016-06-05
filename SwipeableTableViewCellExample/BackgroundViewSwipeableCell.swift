//
//  SwipeableCell.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 16/6/5.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import SwipeableTableViewCell

let kBackgroundViewSwipeableCellID = "BackgroundViewSwipeableCell"

class BackgroundViewSwipeableCell: SwipeableTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = kCellSelectedColor
    }
}
