//
//  NoteHomeViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import SQLite3
import UIKit
// notes_list record current list
var notes_list: [NoteItem] = []

class NoteHomeViewController: LXMBaseViewController {
    @IBOutlet var tableView: UITableView!

//    var dataArray = [TDAlarm]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Note"

        setupTableView()
        setupNavigationBar()
        notes_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        dataArray = NoteManager.sharedInstance.noteArray // swift的数组是struct，是值类型，写的时候要特别注意
        tableView.reloadData()
    }
}

// MARK: - PrivateMethod

fileprivate extension NoteHomeViewController {
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }

    //top button
    func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(NoteHomeViewController.handleAddItemTapped(_:)))
        navigationItem.rightBarButtonItem = addItem

        navigationItem.leftBarButtonItem = editButtonItem
    }
}

// MARK: - Action

extension NoteHomeViewController {
    func handleAddItemTapped(_: UIBarButtonItem) {
        let noteSettingViewController = NoteSettingViewController.loadFromStroyboardWithTargetAlarm(nil)
        noteSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(noteSettingViewController, animated: true, completion: { () -> Void in

        })
    }
}

extension NoteHomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return NoteManager.sharedInstance.noteArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCellIdentifier) as! NoteCell
        let note = NoteManager.sharedInstance.noteArray[indexPath.row]
        // set defualt config
        cell.configWithNote(note, indexPath: indexPath)
        return cell
    }

    // delete the cell
    func tableView(_ tableView: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = NoteManager.sharedInstance.noteArray[indexPath.row]
        if let index = NoteManager.sharedInstance.noteArray.index(of: item) {
            let id_get = NoteManager.sharedInstance.noteArray[index].id
            NoteManager.sharedInstance.noteArray.remove(at: index)

            let sql = "DELETE FROM NoteDB WHERE id=\(id_get);"
            let boolflag = DBManager.shareManager().execute_sql(sql: sql)
            NSLog("delete sql:\(sql)")
            if boolflag {
                NSLog("delete from notedb success, ")
            } else {
                NSLog("delete from notedb failed, ")
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
//            NoteManager.sharedInstance.save()
        }
    }
}

extension NoteHomeViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = NoteManager.sharedInstance.noteArray[indexPath.row]
        let noteSettingViewController = NoteSettingViewController.loadFromStroyboardWithTargetAlarm(note)
        noteSettingViewController.hidesBottomBarWhenPushed = true
        navigationController?.present(noteSettingViewController, animated: true, completion: { () -> Void in

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
        let note = notes_list.remove(at: (sourceIndexPath as NSIndexPath).row)
        notes_list.insert(note, at: (destinationIndexPath as NSIndexPath).row)

        var note_instance = NoteManager.sharedInstance.noteArray.remove(at: (sourceIndexPath as NSIndexPath).row)
        NoteManager.sharedInstance.noteArray.insert(note_instance, at: (destinationIndexPath as NSIndexPath).row)
    }
}
