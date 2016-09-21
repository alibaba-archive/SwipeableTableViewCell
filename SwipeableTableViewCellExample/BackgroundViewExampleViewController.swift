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
    fileprivate(set) var pushEnabled = false

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Helper
    fileprivate func setupUI() {
        tableView.tableFooterView = UIView()
        let switchView: UIView = {
            let titleView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 40)))
            titleView.backgroundColor = UIColor.clear
            let titleLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 99, height: 40)))
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.text = "Push Enabled"
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = UIColor.red
            titleView.addSubview(titleLabel)
            let pushSwitch = UISwitch()
            pushSwitch.frame.origin.x = 99
            pushSwitch.frame.origin.y = (40 - pushSwitch.frame.height) / 2
            pushSwitch.isOn = false
            pushSwitch.addTarget(self, action: #selector(pushSwitchValueChanged(_:)), for: .valueChanged)
            titleView.addSubview(pushSwitch)
            return titleView
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchView)

        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }

    func pushSwitchValueChanged(_ sender: UISwitch) {
        pushEnabled = sender.isOn
    }

    // MARK: - Table view data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "SwipeableCell with background view"
        case 1: return "UITableViewCell with background view"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kBackgroundViewSwipeableCellID, for: indexPath) as! BackgroundViewSwipeableCell
            let delete = NSAttributedString(string: "删除", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
            var deleteAction = SwipeableCellAction(title: delete, image: UIImage(named: "delete-icon"), backgroundColor: UIColor(red: 255 / 255, green: 90 / 255, blue: 29 / 255, alpha: 1)) { _ in
                print("删除")
            }
            let later = NSAttributedString(string: "稍后处理", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
            var laterAction = SwipeableCellAction(title: later, image: UIImage(named: "later-icon"), backgroundColor: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)) { _ in
                print("稍后处理")
            }
            deleteAction.width = 100
            deleteAction.verticalSpace = 6
            laterAction.width = 100
            laterAction.verticalSpace = 6
            cell.actions = [deleteAction, laterAction]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kBackgroundViewCellID, for: indexPath) as! BackgroundViewCell
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushEnabled {
            performSegue(withIdentifier: "PushToViewController", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

@available(iOS 9.0, *)
extension BackgroundViewExampleViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        let previewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        previewController.preferredContentSize = CGSize.zero
        previewingContext.sourceRect = cell.frame
        return previewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
