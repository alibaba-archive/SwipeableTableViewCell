//
//  ExampleMenuViewController.swift
//  SwipeableTableViewCellExample
//
//  Created by 洪鑫 on 16/6/5.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

class ExampleMenuViewController: UITableViewController {
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SwipeableTableViewCell"
        tableView.separatorColor = UIColor(white: 0.1, alpha: 0.1)
    }

    // MARK: - Table view data source and delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Styles Example"
        case 1:
            cell?.textLabel?.text = "BackgroundView Example"
        default:
            break
        }
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("ShowStylesExampleViewController", sender: self)
        case 1:
            performSegueWithIdentifier("ShowBackgroundViewExampleViewController", sender: self)
        default:
            break
        }
    }
}
