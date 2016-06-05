//
//  BackgroundViewExampleViewController.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 16/6/5.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import SwipeableTableViewCell

class BackgroundViewExampleViewController: UITableViewController {
    private(set) var pushEnabled = false

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    private func setupUI() {
        tableView.tableFooterView = UIView()
        let switchView: UIView = {
            let titleView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 40)))
            titleView.backgroundColor = UIColor.clearColor()
            let titleLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 99, height: 40)))
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.text = "Push Enabled"
            titleLabel.font = UIFont.systemFontOfSize(14)
            titleLabel.textColor = UIColor.redColor()
            titleView.addSubview(titleLabel)
            let pushSwitch = UISwitch()
            pushSwitch.frame.origin.x = 99
            pushSwitch.frame.origin.y = (40 - pushSwitch.frame.height) / 2
            pushSwitch.on = false
            pushSwitch.addTarget(self, action: #selector(BackgroundViewExampleViewController.pushSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
            titleView.addSubview(pushSwitch)
            return titleView
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchView)
    }

    func pushSwitchValueChanged(sender: UISwitch) {
        pushEnabled = sender.on
    }

    // MARK: - Table view data source and delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "SwipeableCell with background view"
        case 1: return "UITableViewCell with background view"
        default: return nil
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(kBackgroundViewSwipeableCellID, forIndexPath: indexPath) as! BackgroundViewSwipeableCell
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var deleteAction = SwipeableCellAction(title: delete, image: UIImage(named: "delete-icon"), backgroundColor: UIColor(red: 255 / 255, green: 90 / 255, blue: 29 / 255, alpha: 1)) { Void in
                print("删除")
            }
            let later = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var laterAction = SwipeableCellAction(title: later, image: UIImage(named: "later-icon"), backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { Void in
                print("稍后处理")
            }
            deleteAction.width = 100
            deleteAction.verticalSpace = 6
            laterAction.width = 100
            laterAction.verticalSpace = 6
            cell.actions = [deleteAction, laterAction]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(kBackgroundViewCellID, forIndexPath: indexPath) as! BackgroundViewCell
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if pushEnabled {
            performSegueWithIdentifier("PushToViewController", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
