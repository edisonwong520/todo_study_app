//
//  DCAlarmManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class DCAlarmManager {
    var alarmArray: [DCAlarm]
    static let sharedInstance = DCAlarmManager()

    private let kDCAlarmArraySavedKey = "kDCAlarmArraySavedKey"

    fileprivate init() {
        alarmArray = DBManager.shareManager().find_all_alarm() as! [DCAlarm]
    }
}
