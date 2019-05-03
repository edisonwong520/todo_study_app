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
        var sql = "INSERT INTO ScoreDB (title,score) VALUES('测验1',79);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
        sql = "INSERT INTO ScoreDB (title,score) VALUES('测验2',88);"
        _ = DBManager.shareManager().execute_sql(sql: sql)
    }
}


