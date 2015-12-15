//
//  SwipeableCellAction.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kSwipeableCellActionDefaultWidth: CGFloat = 90

public struct SwipeableCellAction {
    var title: NSAttributedString?
    var image: UIImage?
    var backgroundColor: UIColor?
    var action: (Void) -> Void
    var width: CGFloat = kSwipeableCellActionDefaultWidth
    var index = 0

    public init(title: NSAttributedString?, image: UIImage?, backgroundColor: UIColor?, action: (Void) -> Void) {
        self.title = title
        self.image = image
        self.backgroundColor = backgroundColor
        self.action = action
    }
}
