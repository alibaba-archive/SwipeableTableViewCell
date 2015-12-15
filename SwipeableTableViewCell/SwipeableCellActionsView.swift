//
//  SwipeableCellActionsView.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kActionItemViewTag = 1000
let kImageTitleSpace: CGFloat = 6

class ActionItemView: UIView {
    private(set) var title: NSAttributedString?
    private(set) var image: UIImage?
    private(set) var width: CGFloat = 0
    private(set) var index = 0
    private(set) var action: ((Void)-> Void)!

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .Center
        imageView.backgroundColor = UIColor.clearColor()
        imageView.userInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.userInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    convenience init(action: SwipeableCellAction, index: Int) {
        self.init(frame: CGRectZero)
        tag = kActionItemViewTag
        backgroundColor = action.backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        self.title = action.title
        self.image = action.image
        self.width = action.width
        self.index = index
        self.action = action.action
 
        userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapActionItemView:")
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)

        if let image = image, title = title {
            imageView.image = image
            titleLabel.attributedText = title
            let contentView = UIView()
            contentView.backgroundColor = UIColor.clearColor()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.userInteractionEnabled = false
            contentView.addSubview(imageView)
            contentView.addSubview(titleLabel)
            addSubview(contentView)
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))
            addConstraint(NSLayoutConstraint(item: contentView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[titleLabel]|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]-\(kImageTitleSpace)-[titleLabel]|", options: [], metrics: nil, views: ["imageView": imageView, "titleLabel": titleLabel]))
        } else if let image = image {
            imageView.image = image
            addSubview(imageView)
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        } else if let title = title {
            titleLabel.attributedText = title
            addSubview(titleLabel)
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[titleLabel]|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        }
    }

    func didTapActionItemView(sender: AnyObject) {
        action()
    }
}

class SwipeableCellActionsView: UIView {
    private(set) var cell: SwipeableTableViewCell!
    private(set) var actions: [SwipeableCellAction]!
    lazy var width: NSLayoutConstraint = { [unowned self] in
        let width = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        width.priority = UILayoutPriorityDefaultHigh
        return width
    }()

    convenience init(actions: [SwipeableCellAction], parentCell: SwipeableTableViewCell) {
        self.init(frame: CGRectZero)
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(width)
        self.cell = parentCell
        self.actions = actions
        setActions(actions)
    }

    func setActions(actions: [SwipeableCellAction]) {
        if actions.count == 0 {
            return
        }
        for subview in subviews {
            if subview.tag == kActionItemViewTag {
                subview.removeConstraints(subview.constraints)
                subview.removeFromSuperview()
            }
        }

        var actionItemViews = [ActionItemView]()
        for (index, action) in actions.enumerate() {
            let actionItemView = ActionItemView(action: action, index: index)
            actionItemViews.append(actionItemView)
        }
        var horizontalFormat = String()
        var itemViews = [String: ActionItemView]()
        for (index, actionItemView) in actionItemViews.reverse().enumerate() {
            let itemViewString = "actionItemView\(index)"
            addSubview(actionItemView)
            addConstraint(NSLayoutConstraint(item: actionItemView, attribute: .Width, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1, constant: actionItemView.width))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(itemViewString)]|", options: [], metrics: nil, views: [itemViewString: actionItemView]))
            horizontalFormat += "[\(itemViewString)]"
            itemViews.updateValue(actionItemView, forKey: itemViewString)
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|\(horizontalFormat)|", options: [], metrics: nil, views: itemViews))
    }
}
