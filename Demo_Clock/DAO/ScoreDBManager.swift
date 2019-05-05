//
//  ScoreDBManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

extension DBManager {
    func find_all_score() -> [ScoreItem] {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        let listData = NSMutableArray()
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return listData as! [ScoreItem]
        } else {
            let sql = "SELECT id,title,score FROM ScoreDB"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            // 语句对象
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                // 执行查询
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let scoreitem = ScoreItem()
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        scoreitem.id = Int(strId)!
                    }
                    if let strtitle = getColumnValue(index: 1, stmt: statement!) {
                        scoreitem.title = strtitle
                    }
                    if let strfloat = getColumnValue(index: 2, stmt: statement!) {
                        scoreitem.score = Float(strfloat)!
                    }
                    listData.add(scoreitem)
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
            return listData as! [ScoreItem]
        }
        
    }
    //find each day study time
    func find_all_studytime() -> [StudytimeItem] {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        let listData = NSMutableArray()
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return listData as! [StudytimeItem]
        } else {
            let sql = "SELECT userid,date,studytime FROM StudytimeDB"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            // 语句对象
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                // 执行查询
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let studyitem = StudytimeItem()
                    if let strId = getColumnValue(index: 0, stmt: statement!) {
                        studyitem.userid = Int(strId)!
                    }
                    if let strdate = getColumnValue(index: 1, stmt: statement!) {
                        studyitem.date = strdate
                    }
                    if let strfloat = getColumnValue(index: 2, stmt: statement!) {
                        studyitem.studytime = Float(strfloat)!
                    }
                    listData.add(studyitem)
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
            return listData as! [StudytimeItem]
        }
        
    }
}
