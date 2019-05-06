//
//  CheckinManager.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/5.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation
extension DBManager {
    func get_today_study_time(userid: Int, today: Date) -> Float {
        var result_dict: [Date] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strdate = dateFormatter.string(from: today)
        var sql = "SELECT checkindate FROM CheckinDB WHERE (userid =\(userid) AND checkindate LIKE '\(strdate)%');"
        let cpath = plistFilePath.cString(using: String.Encoding.utf8)
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            NSLog("db open failed")
            return 0
        } else {
            let cSql = sql.cString(using: String.Encoding.utf8)
            var statement: OpaquePointer?
            // 预处理过程
            if sqlite3_prepare_v2(db, cSql!, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let strdate = getColumnValue(index: 0, stmt: statement!) {
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        result_dict.append(dateFormatter.date(from: strdate)!)
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
            print(result_dict)
            if result_dict.count == 0 {
                daka_begin_flag = false
                return 0

            } else {
                if result_dict.count % 2 == 1 {
                    daka_begin_flag = true
                    result_dict.append(result_dict[result_dict.count - 1])
                } else {
                    daka_begin_flag = false
                }
                var total_time: Float = 0
                for index in stride(from: 0, to: result_dict.count, by: 2) {
                    let firstdate = result_dict[index]
                    let lastdate = result_dict[index + 1]
                    let min_interval = firstdate.minuteBetweenDate(toDate: lastdate)
                    var time_interval: Float = 0
                    if min_interval % 60 >= 30 {
                        time_interval = Float(min_interval / 60) + 0.5
                    } else {
                        time_interval = Float(min_interval / 60)
                    }
                    total_time += time_interval
                }
                sql = "DELETE FROM StudytimeDB WHERE (userid=\(userid) AND date='\(strdate)' AND studytime=\(total_time));"
                _ = DBManager.shareManager().execute_sql(sql: sql)
                
                NSLog("insert total studytime")
                sql = "INSERT INTO StudytimeDB(userid,date,studytime)VALUES(\(userid),'\(strdate)',\(total_time));"
                _ = DBManager.shareManager().execute_sql(sql: sql)
                NSLog("insert total studytime")
            }
        }
        return 0
    }
    
    func get_single_col_array(sql: String) -> [String] {
        var result:[String] = []
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
                        result.append(str)
                    }
                }
            }
            sqlite3_close(db)
            sqlite3_finalize(statement)
            return result
        }
        return result
    }
}
