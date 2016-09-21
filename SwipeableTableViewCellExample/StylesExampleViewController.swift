//
//  StylesExampleViewController.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 15/12/15.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit
import SwipeableTableViewCell

let kCellID = "SwipeableTableViewCell"
let kCustomCellID = "CustomSwipeableTableViewCell"

class StylesExampleViewController: UITableViewController, SwipeableTableViewCellDelegate {
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    fileprivate func setupUI() {
        navigationItem.title = "Styles"
        tableView.separatorColor = UIColor(white: 0.1, alpha: 0.1)
    }

    fileprivate func showAlert(_ message: String, dismissHandler: @escaping () -> ()) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            dismissHandler()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TableView data source and delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 70
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 7 == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCustomCellID, for: indexPath) as! SwipeableTableViewCell
            cell.accessoryType = accessoryTypeForCellAtIndexPath(indexPath)
            cell.actions = actionsForCell(cell, indexPath: indexPath)
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: kCellID) as? SwipeableTableViewCell
            if cell == nil {
                cell = SwipeableTableViewCell(style: .default, reuseIdentifier: kCellID)
            }
            cell!.delegate = self
            if indexPath.row % 7 == 1 {
                let customAccessory = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                customAccessory.textAlignment = .center
                customAccessory.text = "❤️"
                customAccessory.backgroundColor = UIColor.clear
                cell!.accessoryView = customAccessory
            } else {
                cell!.accessoryView = nil
                cell!.accessoryType = accessoryTypeForCellAtIndexPath(indexPath)
            }
            cell!.actions = actionsForCell(cell!, indexPath: indexPath)
            if indexPath.row % 7 == 6 {
                cell!.textLabel?.text = "Cell \(indexPath.row) - No Swipe Action"
            } else {
                cell!.textLabel?.text = "Cell \(indexPath.row)"
            }

            cell!.textLabel?.font = UIFont.systemFont(ofSize: 18)
            return cell!
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = indexPath.row % 7 == 5 ? "Did select custom cell" : "Did select cell \(indexPath.row)"
        showAlert(message) { _ in

        }
    }

    fileprivate func accessoryTypeForCellAtIndexPath(_ indexPath: IndexPath) -> UITableViewCellAccessoryType {
        switch indexPath.row % 7 {
        case 0:
            return .none
        case 1:
            return .none
        case 2, 5:
            return .disclosureIndicator
        case 3:
            return .detailDisclosureButton
        case 4:
            return .checkmark
        default:
            return .none
        }
    }

    fileprivate func actionsForCell(_ cell: SwipeableTableViewCell, indexPath: IndexPath) -> [SwipeableCellAction]? {
        switch indexPath.row % 7 {
        case 0, 5:
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.white])
            var deleteAction = SwipeableCellAction(title: delete, image: nil, backgroundColor: UIColor.red) { _ in
                let message = indexPath.row % 7 == 5 ? "Did click “\(delete.string)” on custom cell" : "Did click “\(delete.string)” on cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            let more = NSAttributedString(string: "更多", attributes: [NSForegroundColorAttributeName: UIColor.white])
            var moreAction = SwipeableCellAction(title: more, image: nil, backgroundColor: UIColor.lightGray) { _ in
                let message = indexPath.row % 7 == 5 ? "Did click “\(more.string)” on custom cell" : "Did click “\(more.string)” on cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            moreAction.width = 100
            deleteAction.width = 100
            return [deleteAction, moreAction]

        case 1:
            var deleteAction = SwipeableCellAction(title: NSAttributedString(string: "Delete"), image: nil, backgroundColor: UIColor.red) { _ in
                let message = "Did click “Delete” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            var moreAction = SwipeableCellAction(title: NSAttributedString(string: "More"), image: nil, backgroundColor: UIColor.lightGray) { _ in
                let message = "Did click “More” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            moreAction.width = 100
            deleteAction.width = 100
            return [deleteAction, moreAction]

        case 2:
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
            var deleteAction = SwipeableCellAction(title: delete, image: UIImage(named: "delete-icon"), backgroundColor: UIColor(red: 255 / 255, green: 90 / 255, blue: 29 / 255, alpha: 1)) { _ in
                let message = "Did click “\(delete.string)” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            let later = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
            var laterAction = SwipeableCellAction(title: later, image: UIImage(named: "later-icon"), backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { _ in
                let message = "Did click “\(later.string)” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            deleteAction.width = 100
            deleteAction.verticalSpace = 6
            laterAction.width = 100
            laterAction.verticalSpace = 6
            return [deleteAction, laterAction]

        case 3:
            let crossAction = SwipeableCellAction(title: nil, image: UIImage(named: "cross-icon"), backgroundColor: UIColor(red: 18 / 255, green: 191 / 255, blue: 41 / 255, alpha: 1)) { _ in
                let message = "Did click “Cross” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            let clockAction = SwipeableCellAction(title: nil, image: UIImage(named: "clock-icon"), backgroundColor: UIColor(red: 255 / 255, green: 255 / 255, blue: 89 / 255, alpha: 1)) { _ in
                let message = "Did click “Clock” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            let checkAction = SwipeableCellAction(title: nil, image: UIImage(named: "check-icon"), backgroundColor: UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)) { _ in
                let message = "Did click “Check” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            return [crossAction, clockAction, checkAction]

        case 4:
            let favorite = NSAttributedString(string: "收藏", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
            var favoriteAction = SwipeableCellAction(title: favorite, image: nil, backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { _ in
                let message = "Did click “\(favorite.string)” at cell \(indexPath.row)"
                self.showAlert(message, dismissHandler: { _ in
                    cell.hideActions(animated: true)
                })
            }
            favoriteAction.width = 120
            return [favoriteAction]

        default:
            return nil
        }
    }

    // MARK: - SwipeableTableViewCell delegate
    func swipeableCell(_ cell: SwipeableTableViewCell, isScrollingToState state: SwipeableCellState) {
        let cellState = state == .closed ? "closing" : "opening"
        let cellName = (cell.textLabel?.text)!
        print("“\(cellName)” is \(cellState)...")
    }

    func swipeableCellDidEndScroll(_ cell: SwipeableTableViewCell) {
        let cellName = (cell.textLabel?.text)!
        print("“\(cellName)” did end scroll!")
    }
}
