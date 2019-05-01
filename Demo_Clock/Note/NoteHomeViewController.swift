//
//  TDHomeViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import SQLite3
import UIKit
//todos_list record current list
var todos_list: [ToDoItem] = []

class TDHomeViewController: LXMBaseViewController {
    @IBOutlet var tableView: UITableView!

//    var dataArray = [TDAlarm]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo"

        setupTableView()
        setupNavigationBar()
        todos_list = DBManager.shareManager().findAll() as! [ToDoItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        dataArray = TDAlarmManager.sharedInstance.alarmArray // swift的数组是struct，是值类型，写的时候要特别注意
        tableView.reloadData()
    }
}

// MARK: - PrivateMethod

fileprivate extension TDHomeViewController {
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }

    //top button
    func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TDHomeViewController.handleAddItemTapped(_:)))
        navigationItem.rightBarButtonItem = addItem

        navigationItem.leftBarButtonItem = editButtonItem
    }
}

// MARK: - Action

extension TDHomeViewController {
    func handleAddItemTapped(_: UIBarButtonItem) {
        let clockSettingViewController = TDClockSettingViewController.loadFromStroyboardWithTargetAlarm(nil)
        clockSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(clockSettingViewController, animated: true, completion: { () -> Void in

        })
    }
}

extension TDHomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return TDAlarmManager.sharedInstance.alarmArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TDAlarmCellIdentifier) as! TDAlarmCell
        let alarm = TDAlarmManager.sharedInstance.alarmArray[indexPath.row]
        cell.configWithAlarm(alarm, indexPath: indexPath)
        return cell
    }

    // delete the cell
    func tableView(_ tableView: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = TDAlarmManager.sharedInstance.alarmArray[indexPath.row]
        if let index = TDAlarmManager.sharedInstance.alarmArray.index(of: item) {
            let id_get = TDAlarmManager.sharedInstance.alarmArray[index].id
            TDAlarmManager.sharedInstance.alarmArray.remove(at: index)

            let sql = "DELETE FROM TodoDB WHERE id=\(id_get);"
            let boolflag = DBManager.shareManager().execute_sql(sql: sql)
            if boolflag {
                NSLog("delete from db success, ")
            } else {
                NSLog("delete from db failed, ")
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
//            TDAlarmManager.sharedInstance.save()
        }
    }
}

extension TDHomeViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarm = TDAlarmManager.sharedInstance.alarmArray[indexPath.row]
        let clockSettingViewController = TDClockSettingViewController.loadFromStroyboardWithTargetAlarm(alarm)
        clockSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(clockSettingViewController, animated: true, completion: { () -> Void in

        })
    }

    // Edit mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }

    // Move the cell
    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return isEditing
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let todo = todos_list.remove(at: (sourceIndexPath as NSIndexPath).row)
        todos_list.insert(todo, at: (destinationIndexPath as NSIndexPath).row)

        var alarm_instance = TDAlarmManager.sharedInstance.alarmArray.remove(at: (sourceIndexPath as NSIndexPath).row)
        TDAlarmManager.sharedInstance.alarmArray.insert(alarm_instance, at: (destinationIndexPath as NSIndexPath).row)
//        TDAlarmManager.sharedInstance.save()
    }
}
