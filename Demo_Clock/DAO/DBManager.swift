//
//  DBManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

let DBFILE_NAME = "tododb.sqlite3"

public class DBManager {
    private var db: OpaquePointer?

    // 私有DateFormatter属性
    private var dateFormatter = DateFormatter()
    // 私有沙箱目录中属性列表文件路径
    private var plistFilePath: String!

//    public static let sharedInstance: DBManager = {
//        let instance = DBManager()
//
//        //初始化沙箱目录中属性列表文件路径
//        instance.plistFilePath = instance.applicationDocumentsDirectoryFile()
//        //初始化DateFormatter
//        instance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        //初始化属性列表文件
//        instance.createEditableCopyOfDatabaseIfNeeded()
//
//        return instance
//    }()
    private static let instance: DBManager = DBManager()
    // 单例
    class func shareManager() -> DBManager {
        // 初始化沙箱目录中属性列表文件路径
        instance.plistFilePath = instance.applicationDocumentsDirectoryFile()
        // 初始化DateFormatter
        instance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 初始化属性列表文件
        instance.createEditableCopyOfDatabaseIfNeeded()
        return instance
    }

    // 初始化DB
    private func createEditableCopyOfDatabaseIfNeeded() {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        NSLog(plistFilePath)

        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("open db failed")
        } else {
//            NSLog("open db success")
            let sql = "CREATE TABLE IF NOT EXISTS TodoDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,note TEXT,date DATETIME,priority INTEGER,repeatday VARCHAR(10),alarmOn INTEGER)"
            let cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create table failed")
            }
        }
        sqlite3_close(db)
    }

    private func applicationDocumentsDirectoryFile() -> String {
        let documentDirectory: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let path = (documentDirectory[0] as AnyObject).appendingPathComponent(DBFILE_NAME) as String
        return path
    }

    // 插入TodoiItem方法
    public func insert(todoitem: ToDoItem) {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)

        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return
        } else {
            let sql = "INSERT OR REPLACE INTO TodoDB (title,note,date,priority,repeatday,alarmOn) VALUES (?,?,?,?,?,?)"
            let cSql = sql.cString(using: String.Encoding.utf8)
            // 语句对象
            var statement: OpaquePointer?
            // 预处理过程
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                let cTitle = todoitem.title.cString(using: String.Encoding.utf8)
                let strDate = dateFormatter.string(from: todoitem.date as Date)
                let cNote = todoitem.note.cString(using: String.Encoding.utf8)
                let crepeatday = todoitem.repeatday.cString(using: String.Encoding.utf8)
                let cDate = strDate.cString(using: String.Encoding.utf8)
                let cPriority = todoitem.priority
                let cbool = get_alarm_int(bf: todoitem.alarmOn)
//                let cId = todoitem.id
                // 绑定参数开始
//                sqlite3_bind_int(statement, 1, Int32(cId))
                sqlite3_bind_text(statement, 1, cTitle!, -1, nil)
                sqlite3_bind_text(statement, 2, cNote!, -1, nil)
                sqlite3_bind_text(statement, 3, cDate!, -1, nil)
                sqlite3_bind_int(statement, 4, Int32(cPriority))
                sqlite3_bind_text(statement, 5, crepeatday!, -1, nil)
                sqlite3_bind_int(statement, 6, Int32(cbool))

                // 执行插入
                if sqlite3_step(statement) != SQLITE_DONE {
                    NSLog("insert failed")
                } else {
//                    NSLog("insert success")
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
            return
        }
    }

    // 查询所有数据方法
    public func findAll() -> NSMutableArray {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        let listData = NSMutableArray()
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return listData
        } else {
            let sql = "SELECT title,note,date,priority,repeatday,alarmOn FROM TodoDB"
            let cSql = sql.cString(using: String.Encoding.utf8)

            // 语句对象
            var statement: OpaquePointer?
            // 预处理过程
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                // 执行查询
                while sqlite3_step(statement) == SQLITE_ROW {
                    let todoitem = ToDoItem()
//                    if let strId = getColumnValue(index: 0, stmt: statement!) {
//                        todoitem.id = Int(strId)!
//                    }
                    if let strTitle = getColumnValue(index: 0, stmt: statement!) {
                        todoitem.title = strTitle
                    }
                    if let strNote = getColumnValue(index: 1, stmt: statement!) {
                        todoitem.note = strNote
                    }
                    if let strDate = getColumnValue(index: 2, stmt: statement!) {
                        let date: Date = dateFormatter.date(from: strDate)!
                        todoitem.date = date
                    }
                    if let strPriority = getColumnValue(index: 3, stmt: statement!) {
                        todoitem.priority = Int(strPriority)!
                    }
                    if let strrepeatday = getColumnValue(index: 4, stmt: statement!) {
                        todoitem.note = strrepeatday
                    }
                    if let strBool = getColumnValue(index: 5, stmt: statement!) {
                        let strnum = get_alarm_bool(num: Int(strBool)!)
                        todoitem.alarmOn = strnum
                    }
                    listData.add(todoitem)
                }

                sqlite3_finalize(statement)
                sqlite3_close(db)

                return listData
            } else {
                NSLog("execute sql failed")
            }
        }

        return listData
    }

    public func find_all_alarm() -> NSMutableArray {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        let listData = NSMutableArray()
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return listData
        } else {
            let sql = "SELECT id,date,repeatday,alarmOn FROM TodoDB"
            let cSql = sql.cString(using: String.Encoding.utf8)

            // 语句对象
            var statement: OpaquePointer?
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let alarmitem = DCAlarm()
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        alarmitem.id = Int(strId)!
                    }
                    if let strDate = getColumnValue(index: 1, stmt: statement!) {
                        let date: Date = dateFormatter.date(from: strDate)!
                        alarmitem.alarmDate = date
                    }
                    if let strrepeatday = getColumnValue(index: 2, stmt: statement!) {
                        alarmitem.selectedDay = Int(strrepeatday, radix: 2)!
                    }
                    if let strnum = getColumnValue(index: 3, stmt: statement!) {
                        let aa = get_alarm_bool(num: Int(strnum)!)
                        alarmitem.alarmOn = aa
                    }
                    let strDate1 = getColumnValue(index: 1, stmt: statement!)
                    alarmitem.descriptionText = String(format: "%02x", alarmitem.selectedDay)
                    alarmitem.identifier = strDate1!
                    listData.add(alarmitem)
                }
                sqlite3_finalize(statement)
                sqlite3_close(db)
                return listData
            } else {
                NSLog("execute sql failed")
            }
        }
        return listData
    }

    // excute a sql
    public func execute_sql(sql: String) -> Bool {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)

        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return false
        } else {
            let cSql = sql.cString(using: String.Encoding.utf8)

            // 语句对象
            var statement: OpaquePointer?
            // 预处理过程

            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) != SQLITE_DONE {
                    // error output
                    if let error = String(validatingUTF8: sqlite3_errmsg(db)) {
                        NSLog("wrong sql:\(sql)")
                        NSLog(error)
                    }
                    return false
                } else {
//                    NSLog("execute sql success")
                    sqlite3_close(db)
                    sqlite3_finalize(statement)
                    return true
                }
            }
        }

        return false
    }

    // find id
    public func find_id(date: String, title: String) -> Int {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            let sql = "SELECT id FROM TodoDB WHERE date='\(date)' AND title='\(title)';"
            NSLog("find id sql:\(sql)")
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                // 执行查询
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        sqlite3_close(db)
                        sqlite3_finalize(statement)
                        return Int(strId)!
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
        }
        return -1
    }

    public func switch_id(todo1: ToDoItem, todo2: ToDoItem) {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            // id1
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strdate1 = dateFormatter.string(from: todo1.date)
            let strtitle1 = todo1.title
            let id1 = find_id(date: strdate1, title: strtitle1)

            // id2
            let strdate2 = dateFormatter.string(from: todo2.date)
            let strtitle2 = todo2.title
            let id2 = find_id(date: strdate2, title: strtitle2)

            var sql = "UPDATE TodoDB set id=-1 WHERE id=\(id1);"
            var cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("set id=1 failed")
            }

            sql = "UPDATE TodoDB set id=\(id1) WHERE id=\(id2);"
            cSql = sql.cString(using: String.Encoding.utf8)
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("switch id failed")
            }

            sql = "UPDATE TodoDB set id=\(id2) WHERE id=-1;"
            cSql = sql.cString(using: String.Encoding.utf8)
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("switch id failed")
            }
        }
    }

    public func drop_table() {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            let sql = "drop table 'TodoDB' ;"
            let cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
        }
    }

    // 获得字段数据
    private func getColumnValue(index: CInt, stmt: OpaquePointer) -> String? {
        if let ptr = UnsafeRawPointer(sqlite3_column_text(stmt, index)) {
            let uptr = ptr.bindMemory(to: CChar.self, capacity: 0)
            let txt = String(validatingUTF8: uptr)
            return txt
        }
        return nil
    }

    //
    func get_alarm_bool(num: Int) -> Bool {
        if num == 1 {
            return true
        } else {
            return false
        }
    }

    func get_alarm_int(bf: Bool) -> Int {
        if bf {
            return 1
        } else {
            return 0
        }
    }

//    func get_seleted_int(str: String) -> Int {
//        return Int(str, radix: 2)!
//    }
}
