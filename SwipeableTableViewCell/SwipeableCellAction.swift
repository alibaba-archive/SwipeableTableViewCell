//
//  SwipeableCellAction.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kSwipeableCellActionDefaultWidth: CGFloat = 90
let kSwipeableCellActionDefaultVerticalSpace: CGFloat = 6

public struct SwipeableCellAction {
    public var title: NSAttributedString?
    public var image: UIImage?
    public var backgroundColor: UIColor?
    public var action: (Void) -> Void
    public var width: CGFloat = kSwipeableCellActionDefaultWidth
    public var verticalSpace: CGFloat = kSwipeableCellActionDefaultVerticalSpace

    public init(title: NSAttributedString?, image: UIImage?, backgroundColor: UIColor, action: (Void) -> Void) {
        self.title = title
        self.image = image
        self.backgroundColor = backgroundColor
        self.action = action
    }
}
