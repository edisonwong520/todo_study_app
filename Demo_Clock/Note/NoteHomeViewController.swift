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
// record search result list
var filter_list: [NoteItem] = []
var cell_flag = false
class NoteHomeViewController: LXMBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {
    var searchController: UISearchController!

    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterContentForSearchText(searchString! as NSString, scope: searchController.searchBar.selectedScopeButtonIndex)
        tableView.reloadData()
    }

    // MARK: --实现UISearchBarDelegate协议方法

    func searchBar(_: UISearchBar, selectedScopeButtonIndexDidChange _: Int) {
        updateSearchResults(for: searchController)
    }

    @IBOutlet var tableView: UITableView!

//    var dataArray = [TDAlarm]()

    override func viewDidLoad() {
        super.viewDidLoad()
        notes_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
        title = "笔记"
        // add search bar
        // 实例化UISearchController
        searchController = UISearchController(searchResultsController: nil)
        // 设置self为更新搜索结果对象
        searchController.searchResultsUpdater = self
        // 在搜索是背景设置为灰色
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["标题", "笔记"]
        searchController.searchBar.delegate = self
        // 将搜索栏放到表视图的表头中
        tableView.tableHeaderView = searchController.searchBar

        searchController.searchBar.sizeToFit()

        setupTableView()
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        dataArray = notes_list // swift的数组是struct，是值类型，写的时候要特别注意
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

    // filter the search
    func filterContentForSearchText(_ searchText: NSString, scope: Int) {
        if searchText.length == 0 {
            // 查询所有
            NSLog("find all notes_list")
            filter_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
            tableView.reloadData()
            return
        }

        var sql = ""

//        filter_list =
        if scope == 0 {
            NSLog("scope 0")
            sql = "SELECT id FROM NoteDB WHERE title LIKE '%\(searchText)%';"
            NSLog("search keyword:\(sql)")
            filter_list = DBManager.shareManager().find_keyword(sql) as! [NoteItem]
            cell_flag = true
            tableView.reloadData()
            return
        }
        if scope == 1 {
            NSLog("scope 1")
            sql = "SELECT id FROM NoteDB WHERE context LIKE '%\(searchText)%';"
            NSLog("search keyword:\(sql)")
            filter_list = DBManager.shareManager().find_keyword(sql) as! [NoteItem]
            tableView.reloadData()
            return
        }
//            print(filter_list[0].context)

//        } else {
//            sql = "SELECT id FROM NoteDB WHERE context LIKE '%\(searchText)%' OR title LIKE '%\(searchText)%';"
//            NSLog("search keyword:\(sql)")
//            filter_list = DBManager.shareManager().find_keyword(sql) as! [NoteItem]
//
//        }
    }
}

extension NoteHomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
//        filter_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
//        NSLog("filter list count \(filter_list.count)")
        return filter_list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCellIdentifier) as! NoteCell
        let note = notes_list[indexPath.row]
        // set defualt config

        cell.configWithNote(filter_list[indexPath.row], indexPath: indexPath)

        return cell
    }

    // delete the cell
    func tableView(_ tableView: UITableView, commit _: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = notes_list[indexPath.row]
        if let index = notes_list.index(of: item) {
            let id_get = notes_list[index].id
            notes_list.remove(at: index)

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
        current_selected_row = indexPath.row
        add_item_flag = false
        let note = notes_list[indexPath.row]
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
    }
}
