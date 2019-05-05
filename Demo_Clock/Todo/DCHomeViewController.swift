//
//  DCHomeViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import SQLite3
import UIKit
//todos_list record current list
var todos_list: [ToDoItem] = []
var current_selected_row = 0
var add_item_flag = true
class DCHomeViewController: LXMBaseViewController {
    @IBOutlet var tableView: UITableView!

//    var dataArray = [DCAlarm]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "提醒"

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

//        dataArray = DCAlarmManager.sharedInstance.alarmArray // swift的数组是struct，是值类型，写的时候要特别注意
        tableView.reloadData()
    }
}

// MARK: - PrivateMethod

fileprivate extension DCHomeViewController {
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }

    //top button
    func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(DCHomeViewController.handleAddItemTapped(_:)))
        navigationItem.rightBarButtonItem = addItem

        navigationItem.leftBarButtonItem = editButtonItem
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
        return DCAlarmManager.sharedInstance.alarmArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DCAlarmCellIdentifier) as! DCAlarmCell
        let alarm = DCAlarmManager.sharedInstance.alarmArray[indexPath.row]

        cell.configWithAlarm(alarm, indexPath: indexPath)
        return cell
    }

    // delete the cell
    func tableView(_ tableView: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = DCAlarmManager.sharedInstance.alarmArray[indexPath.row]
        if let index = DCAlarmManager.sharedInstance.alarmArray.index(of: item) {
            let id_get = DCAlarmManager.sharedInstance.alarmArray[index].id
            DCAlarmManager.sharedInstance.alarmArray.remove(at: index)

            let sql = "DELETE FROM TodoDB WHERE id=\(id_get);"
            let boolflag = DBManager.shareManager().execute_sql(sql: sql)
            if boolflag {
                NSLog("delete from db success, ")
            } else {
                NSLog("delete from db failed, ")
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
//            DCAlarmManager.sharedInstance.save()
        }
    }
}

extension DCHomeViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        current_selected_row = indexPath.row
        NSLog("current row is \(current_selected_row)")
        NSLog("current todolist count is \(todos_list.count)")
        add_item_flag = false

        let alarm = DCAlarmManager.sharedInstance.alarmArray[indexPath.row]
        let clockSettingViewController = DCClockSettingViewController.loadFromStroyboardWithTargetAlarm(alarm)
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

        var alarm_instance = DCAlarmManager.sharedInstance.alarmArray.remove(at: (sourceIndexPath as NSIndexPath).row)
        DCAlarmManager.sharedInstance.alarmArray.insert(alarm_instance, at: (destinationIndexPath as NSIndexPath).row)
//        DCAlarmManager.sharedInstance.save()
    }
}
