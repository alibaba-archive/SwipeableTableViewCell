//
//  ExampleViewController.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit
import SwipeableTableViewCell

let kCellID = "SwipeableTableViewCell"

class ExampleViewController: UITableViewController {
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    private func setupUI() {
        navigationItem.title = "SwipeableTableViewCell Example"
    }
    
    // MARK: - TableView data source and delegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? SwipeableTableViewCell
        if cell == nil {
            cell = SwipeableTableViewCell(style: .Default, reuseIdentifier: kCellID)
        }
        cell!.accessoryType = .DisclosureIndicator
        cell!.actions = actionsForCellAtIndexPath(indexPath)
        cell!.textLabel?.text = "Cell \(indexPath.row)"
        cell!.textLabel?.font = UIFont.systemFontOfSize(18)
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    private func actionsForCellAtIndexPath(indexPath: NSIndexPath) -> [SwipeableCellAction] {
        switch indexPath.row % 5 {
        case 0:
            var deleteAction = SwipeableCellAction(title: NSAttributedString(string: "Delete"), image: nil, backgroundColor: UIColor.redColor()) { Void in
                print("Did Click Delete!!!!!")
            }
            var cancelAction = SwipeableCellAction(title: NSAttributedString(string: "Cancel"), image: nil, backgroundColor: UIColor.grayColor()) { Void in
                print("Did Click Cencel!!!!!")
            }
            cancelAction.width = 100
            deleteAction.width = 100
            return [deleteAction, cancelAction]

        case 1:
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var deleteAction = SwipeableCellAction(title: delete, image: UIImage(named: "delete-icon"), backgroundColor: UIColor(red: 255 / 255, green: 90 / 255, blue: 29 / 255, alpha: 1)) { Void in
                print("Did Click Delete!!!!!")
            }
            let later = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var laterAction = SwipeableCellAction(title: later, image: UIImage(named: "later-icon"), backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { Void in
                print("Did Click Later!!!!!")
            }
            deleteAction.width = 100
            laterAction.width = 100
            return [deleteAction, laterAction]
            
        case 2:
            let crossAction = SwipeableCellAction(title: nil, image: UIImage(named: "cross-icon"), backgroundColor: UIColor(red: 18 / 255, green: 191 / 255, blue: 41 / 255, alpha: 1)) { Void in
                print("Did Click Cross!!!!!")
            }
            let clockAction = SwipeableCellAction(title: nil, image: UIImage(named: "clock-icon"), backgroundColor: UIColor(red: 255 / 255, green: 255 / 255, blue: 89 / 255, alpha: 1)) { Void in
                print("Did Click Clock!!!!!")
            }
            let checkAction = SwipeableCellAction(title: nil, image: UIImage(named: "check-icon"), backgroundColor: UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)) { Void in
                print("Did Click Check!!!!!")
            }
            return [crossAction, clockAction, checkAction]
            
        default:
            return []
        }
    }
}

