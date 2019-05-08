//
//  InitDB.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/3.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

extension DBManager {
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
            sql = "CREATE TABLE IF NOT EXISTS NoteDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,context TEXT,createdate DATETIME,userid INTEGER DEFAULT 0)"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create note table failed")
            }
            // create score db
            sql = "CREATE TABLE IF NOT EXISTS ScoreDB (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR,score FLOAT,userid INTEGER DEFAULT 0)"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create score table failed")
            }
            // create user db
            sql = "CREATE TABLE IF NOT EXISTS UserDB (id INTEGER PRIMARY KEY AUTOINCREMENT, realname VARCHAR,name VARCHAR,password VARCHAR,email VARCHAR,picurl VARCHAR DEFAULT '')"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create user table failed")
            }
            sql = "CREATE TABLE IF NOT EXISTS LoginDB (id INTEGER PRIMARY KEY AUTOINCREMENT, flag INTEGER,userid INTEGER)"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create login table failed")
            }
            sql = "CREATE TABLE IF NOT EXISTS CheckinDB (id INTEGER PRIMARY KEY AUTOINCREMENT, userid INTEGER,checkindate DATETIME)"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create login table failed")
            }

            sql = "CREATE TABLE IF NOT EXISTS StudytimeDB (id INTEGER PRIMARY KEY AUTOINCREMENT, userid INTEGER,date DATETIME,studytime FLOAT)"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("create login table failed")
            }
        }
        sqlite3_close(db)
    }

    // initial the db
    public func initDB() {
        current_user_id = 1 
        DBManager.shareManager().drop_table()
        // insert scoredb
        var sql = "INSERT INTO ScoreDB (title,score,userid) VALUES('测验1',65,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO ScoreDB (title,score,userid) VALUES('测验2',82,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO ScoreDB (title,score,userid) VALUES('测验3',73,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO ScoreDB (title,score,userid) VALUES('测验4',96,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO ScoreDB (title,score,userid) VALUES('测验5',86,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO NoteDB (title,context,createdate,userid) VALUES('第一条笔记','This is my fisrt note.','2019-05-04 15:28:13',1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO NoteDB (title,context,createdate,userid) VALUES('今日看书有感','《百年孤独》，是哥伦比亚作家加西亚·马尔克斯创作的长篇小说，是其代表作，也是拉丁美洲魔幻现实主义文学的代表作，被誉为“再现拉丁美洲历史社会图景的鸿篇巨著”。','2019-05-04 15:28:22',1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO TodoDB (title,note,date,priority,repeatday,alarmOn) VALUES('练车','练车地点在吉林大学.','2019-05-04 15:29',1,'0000000',1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT OR REPLACE INTO UserDB (realname,name,password,email,picurl) VALUES ('user','user','c4ca4238a0b923820dcc509a6f75849b','user@qq.com','/Users/edison/Library/Developer/CoreSimulator/Devices/E3EEE923-7B86-4B03-A9F8-A75CFC9AE48E/data/Containers/Data/Application/FBBA3D7C-710A-485C-89BB-DC588DE6605A/Documents4585EFF2-1E47-478A-B66D-054EE37D45D9.jpeg');"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT OR REPLACE INTO LoginDB (flag,userid) VALUES (1,1);"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO CheckinDB (userid,checkindate) VALUES (1,'2019-05-05 08:11:00');"
        _ = DBManager.shareManager().execute_sql(sql: sql)

        sql = "INSERT INTO CheckinDB (userid,checkindate) VALUES (1,'2019-05-05 10:30:00');"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO StudytimeDB (userid,date,studytime) VALUES (1,'2019-05-01',2);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO StudytimeDB (userid,date,studytime) VALUES (1,'2019-05-02',4);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO StudytimeDB (userid,date,studytime) VALUES (1,'2019-05-03',3);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        
        sql = "INSERT INTO StudytimeDB (userid,date,studytime) VALUES (1,'2019-05-04',5);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
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
            sql = "drop table 'CheckinDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }

            sql = "drop table 'StudytimeDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)

            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
            sql = "drop table 'BonusDB' ;"
            cSql = sql.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSql!, nil, nil, nil) != SQLITE_OK {
                NSLog("drop table failed")
            }
        }
    }
}
