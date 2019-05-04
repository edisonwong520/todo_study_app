//
//  UserDBManager.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation
extension DBManager {
    func insert_user_db(user:UserItem){
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return
        } else {
            let sql = "INSERT OR REPLACE INTO UserDB (realname,name,password,email) VALUES ('\(user.realname)','\(user.name)','\(user.password)','\(user.email)');"
            let boolflag = DBManager.shareManager().execute_sql(sql: sql)
            if !boolflag{
                NSLog("insert user failed")
                return
            }else{
                NSLog("insert user success")
            }
            
        }
        
    }
    public func find_user_id(sql:String) -> Int {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            
        } else {
            
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
    
}
