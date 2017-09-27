//
//  SwipeableCellActionsView.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kActionItemViewTag = 1000

class ActionItemView: UIView {
    fileprivate(set) var title: NSAttributedString?
    fileprivate(set) var image: UIImage?
    fileprivate(set) var width: CGFloat = 0
    fileprivate(set) var verticalSpace: CGFloat = 0
    fileprivate(set) var index = 0
    fileprivate(set) var action: (()-> ())!

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.isUserInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    convenience init(action: SwipeableCellAction, index: Int) {
        self.init(frame: CGRect.zero)
        tag = kActionItemViewTag
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = action.backgroundColor
        self.title = action.title
        self.image = action.image
        self.width = action.width
        self.verticalSpace = action.verticalSpace
        self.index = index
        self.action = action.action
 
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActionItemView.didTapActionItemView(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)

        if let image = image, let title = title {
            imageView.image = image
            titleLabel.attributedText = title
            let contentView = UIView()
            contentView.backgroundColor = UIColor.clear
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.isUserInteractionEnabled = false
            contentView.addSubview(imageView)
            contentView.addSubview(titleLabel)
            addSubview(contentView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))
            addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-\(verticalSpace)-[titleLabel]|", options: [], metrics: nil, views: ["imageView": imageView, "titleLabel": titleLabel]))
        } else if let image = image {
            imageView.image = image
            addSubview(imageView)
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        } else if let title = title {
            titleLabel.attributedText = title
            addSubview(titleLabel)
            addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        }
    }

    @objc func didTapActionItemView(_ sender: Any) {
        action()
    }
}

class SwipeableCellActionsView: UIView {
    fileprivate(set) var cell: SwipeableTableViewCell?
    fileprivate(set) var actionItemViews = [ActionItemView]()
    fileprivate var actionItemViewBackgroundColors = [UIColor]()

    convenience init(actions: [SwipeableCellAction]?, parentCell: SwipeableTableViewCell) {
        self.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.cell = parentCell
        setActions(actions)
    }

    func setActions(_ actions: [SwipeableCellAction]?) {
        func resetData() {
            for subview in subviews {
                if subview.tag == kActionItemViewTag {
                    subview.removeConstraints(subview.constraints)
                    subview.removeFromSuperview()
                }
            }
            actionItemViews.removeAll()
        }
        func validActions(_ actions: [SwipeableCellAction]?) -> Bool {
            if let actions = actions {
                return actions.count > 0
            }
            return false
        }

        resetData()
        if !validActions(actions) {
            return
        }

        for (index, action) in actions!.enumerated() {
            let actionItemView = ActionItemView(action: action, index: index)
            actionItemViews.append(actionItemView)
        }
        var horizontalFormat = String()
        var itemViews = [String: ActionItemView]()
        for (index, actionItemView) in actionItemViews.reversed().enumerated() {
            let itemViewString = "actionItemView\(index)"
            addSubview(actionItemView)
            addConstraint(NSLayoutConstraint(item: actionItemView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: actionItemView.width))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[\(itemViewString)]|", options: [], metrics: nil, views: [itemViewString: actionItemView]))
            horizontalFormat += "[\(itemViewString)]"
            itemViews.updateValue(actionItemView, forKey: itemViewString)
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|\(horizontalFormat)|", options: [], metrics: nil, views: itemViews))
    }

    func pushBackgroundColors() {
        actionItemViewBackgroundColors.removeAll()
        for actionItemView in actionItemViews {
            actionItemViewBackgroundColors.append(actionItemView.backgroundColor!)
        }
    }

    func popBackgroundColors() {
        for (index, color) in actionItemViewBackgroundColors.enumerated() {
            let actionItemView = actionItemViews[index]
            actionItemView.backgroundColor = color
        }
        actionItemViewBackgroundColors.removeAll()
    }
}
