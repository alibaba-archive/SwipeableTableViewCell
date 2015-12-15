//
//  SwipeableTableViewCell.swift
//  SwipeableTableViewCell
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

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
    private var scrollView: SwipeableCellScrollView = {
        let scrollView = SwipeableCellScrollView()
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.scrollEnabled = true
        return scrollView
    }()

    lazy var actionsView: SwipeableCellActionsView = { [unowned self] in
        let actions = self.actions ?? []
        let actionsView = SwipeableCellActionsView(actions: actions, parentCell: self)
        actionsView.backgroundColor = UIColor.redColor()
        return actionsView
    }()
    lazy var swipingView: UIView = { [unowned self] in
        let view = UIView(frame: self.bounds)
        return view
        }()
    private var swipingDistance = NSLayoutConstraint()

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
        scrollView.contentSize = CGSizeMake(frame.width + actionsView.frame.width, frame.height)
        scrollView.contentOffset = CGPointMake(0, 0)
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

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        addSubview(actionsView)
        swipingDistance = NSLayoutConstraint(item: actionsView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[actionsView]|", options: [], metrics: nil, views: ["actionsView": actionsView]))
    }

    // MARK: - UIScrollView delegate
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {

    }

    // MARK: - UIGestureRecognizer delegate
    
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