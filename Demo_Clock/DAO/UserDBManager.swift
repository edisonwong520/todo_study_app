//
//  UserDBManager.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation
extension DBManager {
    func login_ornot() -> Bool {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        var flag = false
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return false
        } else {
            let sql = "SELECT flag FROM LoginDB WHERE id=1"
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strflag = getColumnValue(index: 0, stmt: statement!) {
                        if strflag == "1" {
                            flag = true
                        } else {
                            flag = false
                        }
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
                return flag
            }
        }
        return false
    }

    func insert_user_db(user: UserItem) {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)

        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return
        } else {
            let sql = "INSERT OR REPLACE INTO UserDB (realname,name,password,email) VALUES ('\(user.realname)','\(user.name)','\(user.password)','\(user.email)');"
            let boolflag = DBManager.shareManager().execute_sql(sql: sql)
            if !boolflag {
                NSLog("insert user failed")
                return
            } else {
                NSLog("insert user success")
            }
        }
    }

    public func find_user_id(sql: String) -> Int {
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
        return 0
    }

    func find_current_login_id() -> Int {
        var result = 0
        let useritem = UserItem()
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            let sql = "SELECT userid FROM LoginDB WHERE id=1"
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            NSLog("find_current_login_id:\(sql)")
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strid = getColumnValue(index: 0, stmt: statement!) {
                        result = Int(strid)!
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
                return result
            }
        }
        return result
    }

    func find_user_byid(id: Int) -> UserItem {
        let useritem = UserItem()
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            let sql = "SELECT realname,name,password,email FROM UserDB WHERE id=\(id)"
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            NSLog("find_user_byid:\(sql)")
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strrealname = getColumnValue(index: 0, stmt: statement!) {
                        useritem.realname = strrealname
                    }
                    if let strname = getColumnValue(index: 1, stmt: statement!) {
                        useritem.name = strname
                    }
                    if let strpass = getColumnValue(index: 2, stmt: statement!) {
                        useritem.password = strpass
                    }
                    if let stremail = getColumnValue(index: 3, stmt: statement!) {
                        useritem.email = stremail
                    }
                    useritem.id = id
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
                return useritem
            }
        }
        return useritem
    }

    func get_single_col(sql: String) -> String {
        var result = ""
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")

        } else {
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            NSLog("find_user_byid:\(sql)")
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let str = getColumnValue(index: 0, stmt: statement!) {
                        result = str
                        break
                    }
                }
            }
            sqlite3_close(db)
            sqlite3_finalize(statement)
            NSLog("get col result" + result)
            return result
        }
        return ""
    }
}
