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
        return 60
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellID) as? SwipeableTableViewCell
        if cell == nil {
            cell = SwipeableTableViewCell(style: .Default, reuseIdentifier: kCellID)
        }
        if indexPath.row % 6 == 1 {
            let customAccessory = UILabel(frame: CGRectMake(0, 0, 30, 30))
            customAccessory.textAlignment = .Center
            customAccessory.text = "❤️"
            customAccessory.backgroundColor = UIColor.clearColor()
            cell!.accessoryView = customAccessory
        } else {
            cell!.accessoryView = nil
            cell!.accessoryType = accessoryTypeForCellAtIndexPath(indexPath)
        }
        cell!.actions = actionsForCell(cell!, indexPath: indexPath)
        if indexPath.row % 6 == 5 {
            cell!.textLabel?.text = "Cell \(indexPath.row) - No Swipe Action"
        } else {
            cell!.textLabel?.text = "Cell \(indexPath.row)"
        }

        cell!.textLabel?.font = UIFont.systemFontOfSize(18)
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    private func accessoryTypeForCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        switch indexPath.row % 6 {
        case 0:
            return .None
        case 1:
            return .None
        case 2:
            return .DisclosureIndicator
        case 3:
            return .DetailDisclosureButton
        case 4:
            return .Checkmark
        default:
            return .None
        }
    }

    private func actionsForCell(cell: SwipeableTableViewCell, indexPath: NSIndexPath) -> [SwipeableCellAction] {
        switch indexPath.row % 6 {
        case 0:
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            var deleteAction = SwipeableCellAction(title: delete, image: nil, backgroundColor: UIColor.redColor()) { Void in
                let message = "Did click “\(delete.string)” on cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            let more = NSAttributedString(string: "更多", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            var moreAction = SwipeableCellAction(title: more, image: nil, backgroundColor: UIColor.lightGrayColor()) { Void in
                let message = "Did click “\(more.string)” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            moreAction.width = 100
            deleteAction.width = 100
            return [deleteAction, moreAction]

        case 1:
            var deleteAction = SwipeableCellAction(title: NSAttributedString(string: "Delete"), image: nil, backgroundColor: UIColor.redColor()) { Void in
                let message = "Did click “Delete” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            var moreAction = SwipeableCellAction(title: NSAttributedString(string: "More"), image: nil, backgroundColor: UIColor.lightGrayColor()) { Void in
                let message = "Did click “More” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            moreAction.width = 100
            deleteAction.width = 100
            return [deleteAction, moreAction]

        case 2:
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var deleteAction = SwipeableCellAction(title: delete, image: UIImage(named: "delete-icon"), backgroundColor: UIColor(red: 255 / 255, green: 90 / 255, blue: 29 / 255, alpha: 1)) { Void in
                let message = "Did click “\(delete.string)” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            let later = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
            var laterAction = SwipeableCellAction(title: later, image: UIImage(named: "later-icon"), backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { Void in
                let message = "Did click “\(later.string)” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            deleteAction.width = 100
            laterAction.width = 100
            return [deleteAction, laterAction]

        case 3:
            let crossAction = SwipeableCellAction(title: nil, image: UIImage(named: "cross-icon"), backgroundColor: UIColor(red: 18 / 255, green: 191 / 255, blue: 41 / 255, alpha: 1)) { Void in
                let message = "Did click “Cross” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            let clockAction = SwipeableCellAction(title: nil, image: UIImage(named: "clock-icon"), backgroundColor: UIColor(red: 255 / 255, green: 255 / 255, blue: 89 / 255, alpha: 1)) { Void in
                let message = "Did click “Clock” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            let checkAction = SwipeableCellAction(title: nil, image: UIImage(named: "check-icon"), backgroundColor: UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)) { Void in
                let message = "Did click “Check” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            return [crossAction, clockAction, checkAction]

        case 4:
            let favorite = NSAttributedString(string: "收藏", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(16)])
            var favoriteAction = SwipeableCellAction(title: favorite, image: nil, backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { Void in
                let message = "Did click “\(favorite.string)” at cell \(indexPath.row)"
                self.showAlert(massage: message, dismissHandler: { Void in
                    cell.hideActions(animated: true)
                })
            }
            favoriteAction.width = 120
            return [favoriteAction]

        default:
            return []
        }
    }

    private func showAlert(massage message: String, dismissHandler:(Void) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
            dismissHandler()
        }
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

