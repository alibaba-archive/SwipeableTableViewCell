//
//  SwipeableTableViewCell.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kAccessoryTrailingSpace: CGFloat = 15
let kTableViewPanState = "state"

public enum SwipeableCellState {
    case Normal
    case Swiped
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
        return actionsView
    }()
    lazy var clipView: UIView = { [unowned self] in
        let view = UIView(frame: self.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
        }()
    private var clipViewConstraint = NSLayoutConstraint()
    private var layoutUpdating = false

    // MARK: - Life cycle
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

    override public func layoutSubviews() {
        super.layoutSubviews()
        if backgroundColor == UIColor.clearColor() || backgroundColor == nil {
            containerView.backgroundColor = UIColor.whiteColor()
        } else {
            containerView.backgroundColor = backgroundColor
        }

        containerView.frame = contentView.frame
        containerView.frame.size.width = frame.width
        scrollView.contentSize = CGSizeMake(frame.width + actionsView.frame.width, frame.height)
        if !scrollView.tracking && !scrollView.decelerating {
            scrollView.contentOffset = contentOffset(state: state)
        }
        updateCell()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        state = .Normal
        hideActions(animated: false)
    }

    deinit {
        scrollView.delegate = nil
    }

    // MARK: - Overriding
    override public func didMoveToSuperview() {
        tableView = nil
        if let tableView = superview as? UITableView {
            self.tableView = tableView
        } else if let tableView = superview?.superview as? UITableView {
            self.tableView = tableView
        }
    }

    override public var frame: CGRect {
        willSet {
            layoutUpdating = true
        }
        didSet {
            layoutUpdating = false
            let widthChanged = frame.width != oldValue.width
            if widthChanged {
                layoutIfNeeded()
            }
        }
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        actionsView.pushBackgroundColors()
        super.setSelected(selected, animated: animated)
        actionsView.popBackgroundColors()
    }

    override public func didTransitionToState(state: UITableViewCellStateMask) {
        super.didTransitionToState(state)
        if state == .DefaultMask {
            layoutSubviews()
        }
    }

    // MARK: - TableView related
    private func removeOldTableViewPanObserver() {

    }

    private func shouldHighlight() -> Bool {
        if let tableView = tableView, delegate = tableView.delegate {
            if delegate.respondsToSelector("tableView:shouldHighlightRowAtIndexPath:") {
                if let cellIndexPath = tableView.indexPathForCell(self) {
                    return delegate.tableView!(tableView, shouldHighlightRowAtIndexPath: cellIndexPath)
                }
            }
        }
        return true
    }

    private func selectCell() {
        if state == .Swiped {
            return
        }

        if let tableView = tableView, delegate = tableView.delegate {
            var cellIndexPath = tableView.indexPathForCell(self)
            if delegate.respondsToSelector("tableView:willSelectRowAtIndexPath:") {
                if let indexPath = cellIndexPath {
                    cellIndexPath = delegate.tableView!(tableView, willSelectRowAtIndexPath: indexPath)
                }
            }
            if let indexPath = cellIndexPath {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                if delegate.respondsToSelector("tableView:didSelectRowAtIndexPath:") {
                    delegate.tableView!(tableView, didSelectRowAtIndexPath: indexPath)
                }
            }
        }
    }

    private func deselectCell() {
        if state == .Swiped {
            return
        }

        if let tableView = tableView, delegate = tableView.delegate {
            var cellIndexPath = tableView.indexPathForCell(self)
            if delegate.respondsToSelector("tableView:willDeselectRowAtIndexPath:") {
                if let indexPath = cellIndexPath {
                    cellIndexPath = delegate.tableView!(tableView, willDeselectRowAtIndexPath: indexPath)
                }
            }
            if let indexPath = cellIndexPath {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
                if delegate.respondsToSelector("tableView:didDeselectRowAtIndexPath:") {
                    delegate.tableView!(tableView, didDeselectRowAtIndexPath: indexPath)
                }
            }
        }
    }

    // MARK: - Helper
    public func showActions(animated animated: Bool) {
        scrollView.setContentOffset(contentOffset(state: .Swiped), animated: animated)
    }

    public func hideActions(animated animated: Bool) {
        scrollView.setContentOffset(contentOffset(state: .Normal), animated: animated)
    }

    private func contentOffset(state state: SwipeableCellState) -> CGPoint {
        return state == .Swiped ? CGPointMake(actionsView.frame.width, 0) : CGPointZero
    }

    private func updateCell() {
        if layoutUpdating {
            return
        }

        if CGPointEqualToPoint(scrollView.contentOffset, contentOffset(state: .Normal)) {
            state = .Normal
        } else {
            state = .Swiped
        }

        if let frame = contentView.superview?.convertRect(contentView.frame, toView: self) {
            var frame = frame
            frame.size.width = self.frame.width
            clipViewConstraint.constant = min(0, CGRectGetMaxX(frame) - CGRectGetMaxX(self.frame))
 
            if editing {
                print("Cell is editing")
            }

            actionsView.hidden = clipViewConstraint.constant == 0

            if let accessoryView = accessoryView {
                if !editing {
                    accessoryView.frame.origin.x = frame.width - accessoryView.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame)
                }
            } else if accessoryType != .None && !editing {
                if let subviews = scrollView.superview?.subviews {
                    for subview in subviews {
                        if let accessory = subview as? UIButton {
                            accessory.frame.origin.x = frame.width - accessory.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame)
                        } else if NSStringFromClass(subview.dynamicType) == "UITableViewCellDetailDisclosureView" {
                            subview.frame.origin.x = frame.width - subview.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame)
                        }
                    }
                }
            }

            if !scrollView.dragging && !scrollView.decelerating {
                tapGesture.enabled = true
            } else {
                tapGesture.enabled = false
            }

            scrollView.scrollEnabled = !editing
        }

    }

    private func configureSwipeableCell() {
        state = .Normal
        layoutUpdating = false
        scrollView.delegate = self
        containerView = UIView()
        scrollView.addSubview(containerView)
        insertSubview(scrollView, atIndex: 0)
        containerView.addSubview(contentView)

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
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
    }

    // MARK: - Selector
    func scrollViewTapped(gestureRecognizer: UIGestureRecognizer) {
        if state == .Normal {
            if selected {
                deselectCell()
            } else if shouldHighlight() {
                selectCell()
            }
        } else {
            hideActions(animated: true)
        }
    }

    // MARK: - UIScrollView delegate
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentLength = fabs(clipViewConstraint.constant)
        let totalLength = actionsView.frame.width
        var targetLocation = contentOffset(state: .Normal)

        if velocity.x > 0.5 {
            targetLocation = contentOffset(state: .Swiped)
        } else if velocity.x < -0.5 {
            targetLocation = contentOffset(state: .Normal)
        } else {
            if currentLength >= totalLength / 2 {
                targetLocation = contentOffset(state: .Swiped)
            } else {
                targetLocation = contentOffset(state: .Normal)
            }
        }
        targetContentOffset.memory = targetLocation
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
        if !decelerate {
            tapGesture.enabled = true
        }
    }

    // MARK: - UIGestureRecognizer delegate
    override public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
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
            return fabs(yVelocity) <= 0.25
        }
        return true
    }
}