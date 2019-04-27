//
//  DCHomeViewController.swift
//  Demo_Clock
//
//  Created by luxiaoming on 16/1/20.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

import UIKit
import SQLite3
import UIKit
//todos_list record current list
var todos_list: [ToDoItem] = []

class DCHomeViewController: LXMBaseViewController {
    @IBOutlet var tableView: UITableView!

    var dataArray = [DCAlarm]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "闹钟"

        setupTableView()
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dataArray = DCAlarmManager.sharedInstance.alarmArray // swift的数组是struct，是值类型，写的时候要特别注意
        tableView.reloadData()
    }
}

// MARK: - PrivateMethod

fileprivate extension DCHomeViewController {
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }

    func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(DCHomeViewController.handleAddItemTapped(_:)))
        navigationItem.rightBarButtonItem = addItem
    }
}

// MARK: - Action

extension DCHomeViewController {
    func handleAddItemTapped(_: UIBarButtonItem) {
        let clockSettingViewController = DCClockSettingViewController.loadFromStroyboardWithTargetAlarm(nil)
        clockSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(clockSettingViewController, animated: true, completion: { () -> Void in

        })
    }
}

extension DCHomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DCAlarmCellIdentifier) as! DCAlarmCell
        let alarm = dataArray[indexPath.row]
        cell.configWithAlarm(alarm, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        if let index = self.dataArray.index(of: item) {
            dataArray.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
            DCAlarmManager.sharedInstance.save()
        }
    }
}

extension DCHomeViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarm = dataArray[indexPath.row]
        let clockSettingViewController = DCClockSettingViewController.loadFromStroyboardWithTargetAlarm(alarm)
        clockSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(clockSettingViewController, animated: true, completion: { () -> Void in

        })
    }
}
