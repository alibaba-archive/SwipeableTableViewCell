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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ShowStylesExampleViewController", sender: self)
        case 1:
            performSegue(withIdentifier: "ShowBackgroundViewExampleViewController", sender: self)
        default:
            break
        }
    }
}
