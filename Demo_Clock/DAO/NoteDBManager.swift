//
//  DBManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

extension DBManager {
    public func find_all_notes() -> NSMutableArray {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        let listData = NSMutableArray()
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return listData
        } else {
            let sql = "SELECT id,title,createdate,context FROM NoteDB"
            let cSql = sql.cString(using: String.Encoding.utf8)

            // 语句对象
            var statement: OpaquePointer?
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let noteitem = NoteItem()
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        noteitem.id = Int(strId)!
                    }
                    if let strDate = getColumnValue(index: 2, stmt: statement!) {
                        let date: Date = dateFormatter.date(from: strDate)!
                        noteitem.createDate = date
                    }
                    if let strtitle = getColumnValue(index: 1, stmt: statement!) {
                        noteitem.title = strtitle
                    }
                    if let strcontext = getColumnValue(index: 3, stmt: statement!) {
                        noteitem.context = strcontext
                    }

                    listData.add(noteitem)
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

    func insert(noteitem: NoteItem) {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)

        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strDate = dateFormatter.string(from: noteitem.createDate as! Date)
            let sql = "INSERT INTO NoteDB (title,context,createdate,userid) VALUES ('\(noteitem.title)','\(noteitem.context)','\(strDate)',\(current_user_id));"
            NSLog("insert note sql:\(sql)")

            _ = DBManager.shareManager().execute_sql(sql: sql)

            return
        }
    }

    func find_note_id(note: NoteItem) -> Int {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return -1
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strDate = dateFormatter.string(from: note.createDate as! Date)
            let sql = "SELECT id FROM NoteDB WHERE (title='\(note.title)' AND createdate='\(strDate)' AND userid=\(current_user_id));"
            NSLog("select id sql:\(sql)")
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
            return -1
    } }

    func find_keyword(_ sql: String) -> NSMutableArray {
        var result = NSMutableArray()
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        var id_list: [Int] = []
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return result
        } else {
            NSLog("select id sql:\(sql)")
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        id_list.append(Int(strId)!)
                        NSLog("keyword id is \(Int(strId)!)")
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
        }

        // add to the result list
        for id in id_list {
            for note_item in notes_list {
                if id == note_item.id {
                    result.add(note_item)
                    break
                }
            }
        }

        return result
    }
}
