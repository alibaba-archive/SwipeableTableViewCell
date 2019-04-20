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
    case closed
    case swiped
}

public protocol SwipeableTableViewCellDelegate: class {
    func swipeableCell(_ cell: SwipeableTableViewCell, isScrollingToState state: SwipeableCellState)
    func swipeableCellSwipeEnabled(_ cell: SwipeableTableViewCell) -> Bool
    func allowMultipleCellsSwipedSimultaneously() -> Bool
    func swipeableCellDidEndScroll(_ cell: SwipeableTableViewCell)
}

public extension SwipeableTableViewCellDelegate {
    func swipeableCell(_ cell: SwipeableTableViewCell, isScrollingToState state: SwipeableCellState) {

    }

    func swipeableCellSwipeEnabled(_ cell: SwipeableTableViewCell) -> Bool {
        return true
    }

    func allowMultipleCellsSwipedSimultaneously() -> Bool {
        return false
    }

    func swipeableCellDidEndScroll(_ cell: SwipeableTableViewCell) {

    }
}

open class SwipeableTableViewCell: UITableViewCell, UIScrollViewDelegate {
    open weak var delegate: SwipeableTableViewCellDelegate?
    open fileprivate(set) var state: SwipeableCellState = .closed {
        didSet {
            if state != oldValue {
                updateContainerViewBackgroundColor()
            }
        }
    }
    open var actions: [SwipeableCellAction]? {
        didSet {
            actionsView.setActions(actions)
            actionsView.layoutIfNeeded()
            layoutIfNeeded()
        }
    }

    fileprivate weak var tableView: UITableView? {
        didSet {
            removeOldTableViewPanObserver()
            tableViewPanGestureRecognizer = nil
            if let tableView = tableView {
                tableViewPanGestureRecognizer = tableView.panGestureRecognizer
                if let dataSource = tableView.dataSource {
                    if dataSource.responds(to: #selector(UITableViewDataSource.sectionIndexTitles(for:))) {
                        if let _ = dataSource.sectionIndexTitles?(for: tableView) {
                            additionalPadding = kSectionIndexWidth
                        }
                    }
                }
                tableView.isDirectionalLockEnabled = true
                tapGesture.require(toFail: tableView.panGestureRecognizer)
                tableViewPanGestureRecognizer!.addObserver(self, forKeyPath: kTableViewPanState, options: [.new], context: nil)
            }
        }
    }
    fileprivate var tableViewPanGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var additionalPadding: CGFloat = 0 {
        didSet {
            trainingOffset.constant = -additionalPadding
            layoutIfNeeded()
        }
    }
    open fileprivate(set) var containerView: UIView!
    open fileprivate(set) lazy var scrollView: SwipeableCellScrollView = {
        let scrollView = SwipeableCellScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    lazy var tapGesture: UITapGestureRecognizer = { [unowned self] in
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwipeableTableViewCell.scrollViewTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SwipeableTableViewCell.scrollViewLongPressed(_:)))
        longPressGesture.cancelsTouchesInView = false
        longPressGesture.minimumPressDuration = 0.16
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
    fileprivate var clipViewConstraint = NSLayoutConstraint()
    fileprivate var trainingOffset = NSLayoutConstraint()
    fileprivate var isLayoutUpdating = false

    // MARK: - Life cycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSwipeableCell()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSwipeableCell()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateContainerViewBackgroundColor()

        containerView.frame = contentView.frame
        containerView.frame.size.width = frame.width - additionalPadding
        containerView.frame.size.height = frame.height
        scrollView.contentSize = CGSize(width: frame.width + actionsView.frame.width, height: frame.height)
        if !scrollView.isTracking && !scrollView.isDecelerating {
            scrollView.contentOffset = contentOffset(of: state)
        }
        updateCell()
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        if state != .closed {
            hideActions(animated: false)
        }
    }

    deinit {
        scrollView.delegate = nil
        removeOldTableViewPanObserver()
    }

    // MARK: - Overriding
    override open func didMoveToSuperview() {
        tableView = nil
        if let tableView = superview as? UITableView {
            self.tableView = tableView
        } else if let tableView = superview?.superview as? UITableView {
            self.tableView = tableView
        }
    }

    override open var frame: CGRect {
        willSet {
            isLayoutUpdating = true
        }
        didSet {
            isLayoutUpdating = false
            let widthChanged = frame.width != oldValue.width
            if widthChanged {
                layoutIfNeeded()
            }
        }
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        actionsView.pushBackgroundColors()
        super.setSelected(selected, animated: animated)
        actionsView.popBackgroundColors()
    }

    // MARK: - TableView related
    fileprivate func removeOldTableViewPanObserver() {
        tableViewPanGestureRecognizer?.removeObserver(self, forKeyPath: kTableViewPanState)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let object = object as? UIPanGestureRecognizer, let tableViewPanGestureRecognizer = tableViewPanGestureRecognizer  {
            if keyPath == kTableViewPanState && object == tableViewPanGestureRecognizer {
                if let change = change, let new = change[.newKey] as? Int, (new == 2 || new == 3) {
                    setHighlighted(false, animated: false)
                }
            }
        }
    }

    fileprivate func shouldHighlight() -> Bool {
        if let tableView = tableView, let delegate = tableView.delegate {
            if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))) {
                if let cellIndexPath = tableView.indexPathForRow(at: center) {
                    return delegate.tableView!(tableView, shouldHighlightRowAt: cellIndexPath)
                }
            }
        }
        return true
    }

    fileprivate func selectCell() {
        if state == .swiped {
            return
        }

        if let tableView = tableView, let delegate = tableView.delegate {
            var cellIndexPath = tableView.indexPathForRow(at: center)
            if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))) {
                if let indexPath = cellIndexPath {
                    cellIndexPath = delegate.tableView!(tableView, willSelectRowAt: indexPath)
                }
            }
            if let indexPath = cellIndexPath {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))) {
                    delegate.tableView!(tableView, didSelectRowAt: indexPath)
                }
            }
        }
    }

    fileprivate func deselectCell() {
        if state == .swiped {
            return
        }

        if let tableView = tableView, let delegate = tableView.delegate {
            var cellIndexPath = tableView.indexPathForRow(at: center)
            if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))) {
                if let indexPath = cellIndexPath {
                    cellIndexPath = delegate.tableView!(tableView, willDeselectRowAt: indexPath)
                }
            }
            if let indexPath = cellIndexPath {
                tableView.deselectRow(at: indexPath, animated: false)
                if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))) {
                    delegate.tableView!(tableView, didDeselectRowAt: indexPath)
                }
            }
        }
    }

    // MARK: - Helper
    open func showActions(animated: Bool) {
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(self.contentOffset(of: .swiped), animated: animated)
            self.delegate?.swipeableCell(self, isScrollingToState: .swiped)
        }
    }

    open func hideActions(animated: Bool) {
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(self.contentOffset(of: .closed), animated: animated)
            self.delegate?.swipeableCell(self, isScrollingToState: .closed)
        }
    }

    open func hideAllOtherCellsActions(animated: Bool) {
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

    fileprivate func contentOffset(of state: SwipeableCellState) -> CGPoint {
        return state == .swiped ? CGPoint(x: actionsView.frame.width, y: 0) : .zero
    }

    fileprivate func updateCell() {
        if isLayoutUpdating {
            return
        }

        if scrollView.contentOffset.equalTo(contentOffset(of: .closed)) {
            state = .closed
        } else {
            state = .swiped
        }

        if let frame = contentView.superview?.convert(contentView.frame, to: self) {
            var frame = frame
            frame.size.width = self.frame.width
            clipViewConstraint.constant = min(0, frame.maxX - self.frame.maxX)

            actionsView.isHidden = clipViewConstraint.constant == 0

            if let accessoryView = accessoryView {
                if !isEditing {
                    accessoryView.frame.origin.x = frame.width - accessoryView.frame.width - kAccessoryTrailingSpace + frame.minX - additionalPadding
                }
            } else if accessoryType != .none && !isEditing {
                if let subviews = scrollView.superview?.subviews {
                    for subview in subviews {
                        if let accessory = subview as? UIButton {
                            accessory.frame.origin.x = frame.width - accessory.frame.width - kAccessoryTrailingSpace + frame.minX - additionalPadding
                        } else if String(describing: type(of: subview)) == "UITableViewCellDetailDisclosureView" {
                            subview.frame.origin.x = frame.width - subview.frame.width - kAccessoryTrailingSpace + frame.minX - additionalPadding
                        }
                    }
                }
            }

            if !scrollView.isDragging && !scrollView.isDecelerating {
                tapGesture.isEnabled = true
                longPressGesture.isEnabled = state == .closed
            } else {
                tapGesture.isEnabled = false
                longPressGesture.isEnabled = false
            }

            scrollView.isScrollEnabled = !isEditing
        }

    }

    fileprivate func configureSwipeableCell() {
        state = .closed
        isLayoutUpdating = false
        scrollView.delegate = self
        containerView = UIView()
        scrollView.addSubview(containerView)
        insertSubview(scrollView, at: 0)
        containerView.addSubview(contentView)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        tapGesture.delegate = self
        scrollView.addGestureRecognizer(tapGesture)
        longPressGesture.delegate = self
        scrollView.addGestureRecognizer(longPressGesture)

        scrollView.insertSubview(clipView, at: 0)
        clipViewConstraint = NSLayoutConstraint(item: clipView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        clipViewConstraint.priority = .defaultHigh
        trainingOffset = NSLayoutConstraint(item: clipView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: clipView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(trainingOffset)
        addConstraint(clipViewConstraint)

        clipView.addSubview(actionsView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
    }

    fileprivate func updateContainerViewBackgroundColor() {
        if isSelected || isHighlighted || state == .closed {
            containerView.backgroundColor = .clear
        } else {
            if backgroundColor == .clear || backgroundColor == nil {
                containerView.backgroundColor = .white
            } else {
                containerView.backgroundColor = backgroundColor
            }
        }
    }

    fileprivate func shouldAllowMultipleCellsSwipedSimultaneously() -> Bool {
        return delegate?.allowMultipleCellsSwipedSimultaneously() ?? false
    }

    fileprivate func swipeEnabled() -> Bool {
        return delegate?.swipeableCellSwipeEnabled(self) ?? true
    }

    // MARK: - Selector
    @objc func scrollViewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        if state == .closed {
            if let tableView = tableView {
                if tableView.hasSwipedCells() {
                    hideAllOtherCellsActions(animated: true)
                    return
                }
            }

            if isSelected {
                deselectCell()
            } else if shouldHighlight() {
                selectCell()
            }
        } else {
            hideActions(animated: true)
        }
    }

    @objc func scrollViewLongPressed(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if shouldHighlight() && !isHighlighted {
                setHighlighted(true, animated: false)
            }

        case .ended:
            if isHighlighted {
                setHighlighted(false, animated: false)
                scrollViewTapped(gestureRecognizer)
            }

        case .cancelled, .failed:
            setHighlighted(false, animated: false)

        default:
            break
        }
    }

    // MARK: - UIScrollView delegate
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentLength = abs(clipViewConstraint.constant)
        let totalLength = actionsView.frame.width
        var targetState: SwipeableCellState = .closed

        if velocity.x > 0.5 {
            targetState = .swiped
        } else if velocity.x < -0.5 {
            targetState = .closed
        } else {
            if currentLength >= totalLength / 2 {
                targetState = .swiped
            } else {
                targetState = .closed
            }
        }
        let targetLocation = contentOffset(of: targetState)
        targetContentOffset.pointee = targetLocation

        delegate?.swipeableCell(self, isScrollingToState: targetState)

        if state != .closed && !shouldAllowMultipleCellsSwipedSimultaneously() {
            hideAllOtherCellsActions(animated: true)
        }
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelected {
            deselectCell()
        }
        if !swipeEnabled() {
            scrollView.contentOffset = contentOffset(of: .closed)
        }
        updateCell()
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCell()
        delegate?.swipeableCellDidEndScroll(self)
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCell()
        delegate?.swipeableCellDidEndScroll(self)
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            tapGesture.isEnabled = true
        }
    }

    // MARK: - UIGestureRecognizer delegate
    override open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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

    override open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view is UIControl)
        }
        return true
    }
}

public class SwipeableCellScrollView: UIScrollView {
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let translation = gesture.translation(in: gesture.view)
            return abs(translation.y) <= abs(translation.x)
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let yVelocity = gesture.velocity(in: gesture.view).y
            return abs(yVelocity) <= 0.25
        }
        return true
    }
}

public extension UITableView {
    func hideAllSwipeableCellsActions(animated: Bool) {
        for cell in visibleCells {
            if let cell = cell as? SwipeableTableViewCell {
                cell.hideActions(animated: animated)
            }
        }
    }

    func hasSwipedCells() -> Bool {
        for cell in visibleCells {
            if let cell = cell as? SwipeableTableViewCell {
                if cell.state == .swiped {
                    return true
                }
            }
        }
        return false
    }
}
