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
        var result_dict: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strdate = dateFormatter.string(from: today)
        var sql = "SELECT checkindate FROM CheckinDB WHERE (userid =\(userid) AND checkindate LIKE '\(strdate)%' AND sumflag=0);"
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
                        result_dict.append(strdate)
                    }
                }
                sqlite3_close(db)
                sqlite3_finalize(statement)
            }
            print(result_dict)
            if result_dict.count != 0 {
                let fisrtstr = result_dict[0]
                let laststr = result_dict[result_dict.count - 1]
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let firstdate = dateFormatter.date(from: fisrtstr)
                let lastdate = dateFormatter.date(from: laststr)
                let min_interval = firstdate?.minuteBetweenDate(toDate: lastdate!)
                NSLog("min_interval:\(min_interval)")
                if min_interval!%60 >= 30{
                    return Float(min_interval!/60) + 0.5
                }else{
                    return Float(min_interval!/60)
                }
            }
        }
        return 0
    }
}
