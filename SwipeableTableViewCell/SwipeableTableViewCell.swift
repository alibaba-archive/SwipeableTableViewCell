//
//  SwipeableTableViewCell.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kAccessoryTrailingSpace: CGFloat = 15

public enum SwipeableCellState {
    case Normal
    case Swiping
}

public protocol SwipeableTableViewCellDelegate {
    
}

public class SwipeableTableViewCell: UITableViewCell, UIScrollViewDelegate {
    public var delegate: SwipeableTableViewCellDelegate?
    private(set) var state = SwipeableCellState.Normal
    public var actions: [SwipeableCellAction]? {
        didSet {
            if let actions = actions {
                actionsView.setActions(actions)
                actionsView.layoutIfNeeded()
                layoutIfNeeded()
            }
        }
    }

    private var tableView: UITableView?
    private var tableViewPanGestureRecognizer: UIPanGestureRecognizer?
    private var containerView: UIView!
    lazy var scrollView: SwipeableCellScrollView = {
        let scrollView = SwipeableCellScrollView()
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.scrollEnabled = true
        return scrollView
    }()
    lazy var tapGesture: UITapGestureRecognizer = { [unowned self] in
        let tapGesture = UITapGestureRecognizer(target: self, action: "scrollViewTapped:")
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()

    lazy var actionsView: SwipeableCellActionsView = { [unowned self] in
        let actions = self.actions ?? []
        let actionsView = SwipeableCellActionsView(actions: actions, parentCell: self)
        actionsView.backgroundColor = UIColor.redColor()
        return actionsView
    }()
    lazy var clipView: UIView = { [unowned self] in
        let view = UIView(frame: self.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
        }()
    private var clipViewConstraint = NSLayoutConstraint()

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSwipeableCell()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSwipeableCell()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        configureSwipeableCell()
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = contentView.frame
        scrollView.contentSize = CGSizeMake(frame.width + actionsView.frame.width, frame.height)
        if !scrollView.tracking && !scrollView.decelerating {
            scrollView.contentOffset = contentOffset()
        }
        updateCell()
    }

    deinit {
        scrollView.delegate = nil
    }

    public func hideActions(animated animated: Bool) {
        
    }

    private func configureSwipeableCell() {
        scrollView.delegate = self
        containerView = UIView()
        scrollView.addSubview(containerView)
        insertSubview(scrollView, atIndex: 0)
        containerView.addSubview(contentView)
        contentView.backgroundColor = UIColor.purpleColor()

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        tapGesture.delegate = self
        scrollView.addGestureRecognizer(tapGesture)

        scrollView.insertSubview(clipView, atIndex: 0)
        clipViewConstraint = NSLayoutConstraint(item: clipView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        clipViewConstraint.priority = UILayoutPriorityDefaultHigh
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(clipViewConstraint)

        clipView.addSubview(actionsView)
        clipView.backgroundColor = UIColor.orangeColor()
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraint(NSLayoutConstraint(item: actionsView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: contentView, attribute: .Width, multiplier: 1, constant: 0))
    }

    private func updateCell() {
        if let frame = contentView.superview?.convertRect(contentView.frame, toView: self) {
            var frame = frame
            frame.size.width = self.frame.width
            clipViewConstraint.constant = min(0, CGRectGetMaxX(frame) - CGRectGetMaxX(self.frame))
            actionsView.hidden = clipViewConstraint.constant == 0

            if accessoryType != .None && !editing {
                if let subviews = scrollView.superview?.subviews {
                    for subview in subviews {
                        if let accessory = subview as? UIButton {
                            accessory.frame.origin.x = frame.width - accessory.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame)
                        }
                    }
                }
            }

        }
        
    }

    private func contentOffset() -> CGPoint {
        return state == .Swiping ? CGPointMake(actionsView.frame.width, 0) : CGPointZero
    }

    // MARK: - Selector
    func scrollViewTapped(gestureRecognizer: UIGestureRecognizer) {
        print("scrollViewTapped!!!")
    }

    // MARK: - UIScrollView delegate
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x >= 0.5 {
            print("velocity.x >= 0.5")
        } else if velocity.x <= -0.5 {
            print("velocity.x <= -0.5")
        } else {
            
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCell()
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateCell()
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateCell()
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }

    // MARK: - UIGestureRecognizer delegate
    public override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view {
            return !view.isKindOfClass(UIControl.self)
        }
        return true
    }
}

class SwipeableCellScrollView: UIScrollView {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let translation = gesture.translationInView(gesture.view)
            return fabs(translation.y) <= fabs(translation.x)
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let yVelocity = gesture.velocityInView(gesture.view).y
            return yVelocity <= 0.25
        }
        return true
    }
}