//
//  DBManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

extension DBManager{
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

    
}
