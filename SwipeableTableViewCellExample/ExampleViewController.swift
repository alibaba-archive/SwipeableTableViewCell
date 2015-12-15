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
        return 10
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
        let deleteAction =  SwipeableCellAction(title: NSAttributedString(string: "Delete"), image: nil, backgroundColor: UIColor.redColor()) { Void in
            print("Did Click Delete!!!!!")
        }
        let cancelAction =  SwipeableCellAction(title: NSAttributedString(string: "Cancel"), image: nil, backgroundColor: UIColor.blueColor()) { Void in
            print("Did Click Cencel!!!!!")
        }
        cell!.actions = [deleteAction, cancelAction]
        cell!.textLabel?.text = "Cell \(indexPath.row)"
        return cell!
    }
}

