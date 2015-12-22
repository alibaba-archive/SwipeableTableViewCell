//
//  SwipeableTableViewCell.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

let kAccessoryTrailingSpace: CGFloat = 15
let kSectionIndexWidth: CGFloat = 15
let kTableViewPanState = "state"

public enum SwipeableCellState {
    case Closed
    case Swiped
}

public protocol SwipeableTableViewCellDelegate {
    func swipeableCell(cell: SwipeableTableViewCell, scrollingToState state: SwipeableCellState)
    func swipeableCellSwipeEnabled(cell: SwipeableTableViewCell) -> Bool
    func allowMultipleCellsSwipedSimultaneously() -> Bool
    func swipeableCellDidEndScroll(cell: SwipeableTableViewCell)
}

public extension SwipeableTableViewCellDelegate {
    func swipeableCell(cell: SwipeableTableViewCell, scrollingToState state: SwipeableCellState) {

    }

    func swipeableCellSwipeEnabled(cell: SwipeableTableViewCell) -> Bool {
        return true
    }

    func allowMultipleCellsSwipedSimultaneously() -> Bool {
        return false
    }

    func swipeableCellDidEndScroll(cell: SwipeableTableViewCell) {

    }
}

public class SwipeableTableViewCell: UITableViewCell, UIScrollViewDelegate {
    public var delegate: SwipeableTableViewCellDelegate?
    private(set) var state: SwipeableCellState = .Closed
    public var actions: [SwipeableCellAction]? {
        didSet {
            actionsView.setActions(actions)
            actionsView.layoutIfNeeded()
            layoutIfNeeded()
        }
    }

    private var tableView: UITableView? {
        didSet {
            removeOldTableViewPanObserver()
            if let tableView = tableView {
                tableViewPanGestureRecognizer = tableView.panGestureRecognizer
                if let dataSource = tableView.dataSource {
                    if dataSource.respondsToSelector("sectionIndexTitlesForTableView:") {
                        if let _ = dataSource.sectionIndexTitlesForTableView!(tableView) {
                            additionalPadding = kSectionIndexWidth
                        }
                    }
                }
                tableView.directionalLockEnabled = true
                tapGesture.requireGestureRecognizerToFail(tableView.panGestureRecognizer)
                tableViewPanGestureRecognizer!.addObserver(self, forKeyPath: kTableViewPanState, options: [], context: nil)
            }
        }
    }
    private var tableViewPanGestureRecognizer: UIPanGestureRecognizer?
    private var additionalPadding: CGFloat = 0 {
        didSet {
            trainingOffset.constant = -additionalPadding
            layoutIfNeeded()
        }
    }
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
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "scrollViewLongPressed:")
        longPressGesture.cancelsTouchesInView = false
        return longPressGesture
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
    private var trainingOffset = NSLayoutConstraint()
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

    override public func layoutSubviews() {
        super.layoutSubviews()
        configureContainerViewBackgroundColor()

        containerView.frame = contentView.frame
        containerView.frame.size.width = frame.width - additionalPadding
        containerView.frame.size.height = frame.height
        scrollView.contentSize = CGSizeMake(frame.width + actionsView.frame.width, frame.height)
        if !scrollView.tracking && !scrollView.decelerating {
            scrollView.contentOffset = contentOffset(state: state)
        }
        updateCell()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        if state != .Closed {
            state = .Closed
            hideActions(animated: false)
        }
    }

    deinit {
        scrollView.delegate = nil
        removeOldTableViewPanObserver()
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
        tableViewPanGestureRecognizer?.removeObserver(self, forKeyPath: kTableViewPanState)
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath, object = object as? UIPanGestureRecognizer, tableViewPanGestureRecognizer = tableViewPanGestureRecognizer  {
            if keyPath == kTableViewPanState && object == tableViewPanGestureRecognizer {
                let locationInTableView = tableViewPanGestureRecognizer.locationInView(tableView)
                let inCurrentCell = CGRectContainsPoint(frame, locationInTableView)
                if !inCurrentCell && state != .Closed && !shouldAllowMultipleCellsSwipedSimultaneously() {
                    hideAllOtherCellsActions(animated: true)
                }
            }
        }
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
        if let delegate = delegate {
            delegate.swipeableCell(self, scrollingToState: .Swiped)
        }
    }

    public func hideActions(animated animated: Bool) {
        scrollView.setContentOffset(contentOffset(state: .Closed), animated: animated)
        if let delegate = delegate {
            delegate.swipeableCell(self, scrollingToState: .Closed)
        }
    }

    public func hideAllOtherCellsActions(animated animated: Bool) {
        if let tableView = tableView {
            for cell in tableView.visibleCells {
                if let cell = cell as? SwipeableTableViewCell {
                    if cell != self {
                        cell.hideActions(animated: animated)
                    }
                }
            }
        }
    }

    private func contentOffset(state state: SwipeableCellState) -> CGPoint {
        return state == .Swiped ? CGPointMake(actionsView.frame.width, 0) : CGPointZero
    }

    private func updateCell() {
        if layoutUpdating {
            return
        }

        if CGPointEqualToPoint(scrollView.contentOffset, contentOffset(state: .Closed)) {
            state = .Closed
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
                    accessoryView.frame.origin.x = frame.width - accessoryView.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame) - additionalPadding
                }
            } else if accessoryType != .None && !editing {
                if let subviews = scrollView.superview?.subviews {
                    for subview in subviews {
                        if let accessory = subview as? UIButton {
                            accessory.frame.origin.x = frame.width - accessory.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame) - additionalPadding
                        } else if NSStringFromClass(subview.dynamicType) == "UITableViewCellDetailDisclosureView" {
                            subview.frame.origin.x = frame.width - subview.frame.width - kAccessoryTrailingSpace + CGRectGetMinX(frame) - additionalPadding
                        }
                    }
                }
            }

            if !scrollView.dragging && !scrollView.decelerating {
                tapGesture.enabled = true
                longPressGesture.enabled = state == .Closed
            } else {
                tapGesture.enabled = false
                longPressGesture.enabled = false
            }

            scrollView.scrollEnabled = !editing
        }

    }

    private func configureSwipeableCell() {
        state = .Closed
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
        longPressGesture.delegate = self
        scrollView.addGestureRecognizer(longPressGesture)

        scrollView.insertSubview(clipView, atIndex: 0)
        clipViewConstraint = NSLayoutConstraint(item: clipView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        clipViewConstraint.priority = UILayoutPriorityDefaultHigh
        trainingOffset = NSLayoutConstraint(item: clipView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(trainingOffset)
        addConstraint(clipViewConstraint)

        clipView.addSubview(actionsView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
    }

    private func configureContainerViewBackgroundColor() {
        if selected {
            containerView.backgroundColor = UIColor.clearColor()
        } else {
            if backgroundColor == UIColor.clearColor() || backgroundColor == nil {
                containerView.backgroundColor = UIColor.whiteColor()
            } else {
                containerView.backgroundColor = backgroundColor
            }
        }
    }

    private func shouldAllowMultipleCellsSwipedSimultaneously() -> Bool {
        if let delegate = delegate {
            return delegate.allowMultipleCellsSwipedSimultaneously()
        }
        return false
    }

    private func swipeEnabled() -> Bool {
        if let delegate = delegate {
            return delegate.swipeableCellSwipeEnabled(self)
        }
        return true
    }

    // MARK: - Selector
    func scrollViewTapped(gestureRecognizer: UIGestureRecognizer) {
        if state == .Closed {
            if let tableView = tableView {
                if tableView.hasSwipedCells() {
                    hideAllOtherCellsActions(animated: true)
                    return
                }
            }

            if selected {
                deselectCell()
            } else if shouldHighlight() {
                selectCell()
            }
        } else {
            hideActions(animated: true)
        }
    }

    func scrollViewLongPressed(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            if shouldHighlight() && !highlighted {
                setHighlighted(true, animated: false)
            }

        case .Ended:
            setHighlighted(false, animated: false)
            scrollViewTapped(gestureRecognizer)

        case .Cancelled:
            setHighlighted(false, animated: false)

        default:
            break
        }
    }

    // MARK: - UIScrollView delegate
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentLength = fabs(clipViewConstraint.constant)
        let totalLength = actionsView.frame.width
        var targetState: SwipeableCellState = .Closed

        if velocity.x > 0.5 {
            targetState = .Swiped
        } else if velocity.x < -0.5 {
            targetState = .Closed
        } else {
            if currentLength >= totalLength / 2 {
                targetState = .Swiped
            } else {
                targetState = .Closed
            }
        }
        let targetLocation = contentOffset(state: targetState)
        targetContentOffset.memory = targetLocation

        if let delegate = delegate {
            delegate.swipeableCell(self, scrollingToState: targetState)
        }

        if state != .Closed && !shouldAllowMultipleCellsSwipedSimultaneously() {
            hideAllOtherCellsActions(animated: true)
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if selected {
            deselectCell()
        }
        if !swipeEnabled() {
            scrollView.contentOffset = contentOffset(state: .Closed)
        }
        updateCell()
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateCell()
        if let delegate = delegate {
            delegate.swipeableCellDidEndScroll(self)
        }
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateCell()
        if let delegate = delegate {
            delegate.swipeableCellDidEndScroll(self)
        }
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            tapGesture.enabled = true
        }
    }

    // MARK: - UIGestureRecognizer delegate
    override public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = tableView?.panGestureRecognizer {
            if (gestureRecognizer == panGesture && otherGestureRecognizer == longPressGesture) || (gestureRecognizer == longPressGesture && otherGestureRecognizer == panGesture) {
                if let tableView = tableView {
                    if tableView.hasSwipedCells() {
                        hideAllOtherCellsActions(animated: true)
                    }
                }
                return true
            }
        }
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

public extension UITableView {
    public func hideAllSwipeableCellsActions(animated: Bool) {
        for cell in visibleCells {
            if let cell = cell as? SwipeableTableViewCell {
                cell.hideActions(animated: animated)
            }
        }
    }

    public func hasSwipedCells() -> Bool {
        for cell in visibleCells {
            if let cell = cell as? SwipeableTableViewCell {
                if cell.state == .Swiped {
                    return true
                }
            }
        }
        return false
    }
}
