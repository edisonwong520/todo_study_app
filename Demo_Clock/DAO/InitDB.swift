//
//  InitDB.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/3.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation

extension DBManager {
    // initial the db
    public func initDB() {
        DBManager.shareManager().drop_table()
        // insert scoredb
        var sql = "INSERT INTO ScoreDB (title,score) VALUES('测验1',65);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO ScoreDB (title,score) VALUES('测验2',82);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO ScoreDB (title,score) VALUES('测验3',73);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO NoteDB (title,context,createdate) VALUES('第一条笔记','This is my fisrt note.','2019-05-04 15:28:13');"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO TodoDB (title,note,date,priority,repeatday,alarmOn) VALUES('练车','练车地点在吉林大学.','2019-05-04 15:29',1,'0000000',1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT OR REPLACE INTO UserDB (realname,name,password,email) VALUES ('user','user','c4ca4238a0b923820dcc509a6f75849b','user@qq.com');"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT OR REPLACE INTO LoginDB (flag,userid) VALUES (1,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
    }
    
    
    // 初始化DB
    public func createEditableCopyOfDatabaseIfNeeded() {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        NSLog(plistFilePath)
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("open db failed")
        } else {
            var sql = "CREATE TABLE IF NOT EXISTS TodoDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,note TEXT,date DATETIME,priority INTEGER,repeatday VARCHAR(10),alarmOn INTEGER)"
            var cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create todo table failed")
            }
            // create note db
            sql = "CREATE TABLE IF NOT EXISTS NoteDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,context TEXT,createdate DATETIME)"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create note table failed")
            }
            // create score db
            sql = "CREATE TABLE IF NOT EXISTS ScoreDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,score FLOAT)"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create score table failed")
            }
            // create user db
            sql = "CREATE TABLE IF NOT EXISTS UserDB (id INTEGER PRIMARY KEY AUTOINCREMENT, realname VARCHAR,name VARCHAR,password VARCHAR,email VARCHAR)"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create user table failed")
            }
            sql = "CREATE TABLE IF NOT EXISTS LoginDB (id INTEGER PRIMARY KEY AUTOINCREMENT, flag INTEGER,userid INTEGER)"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create login table failed")
            }
        }
        sqlite3_close(db)
    }
    
    
    public func drop_table() {
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            
        } else {
            var sql = "drop table 'TodoDB' ;"
            var cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
            sql = "drop table 'NoteDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
            sql = "drop table 'ScoreDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
            sql = "drop table 'UserDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
            sql = "drop table 'LoginDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
        }
    }
}
