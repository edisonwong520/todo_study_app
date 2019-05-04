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
        
        
    }
}


