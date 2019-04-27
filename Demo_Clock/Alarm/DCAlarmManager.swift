//
//  DCAlarmManager.swift
//  Demo_Clock
//
//  Created by luxiaoming on 16/1/21.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

import UIKit

class DCAlarmManager {
    var alarmArray: [DCAlarm]
    static let sharedInstance = DCAlarmManager()

    private let kDCAlarmArraySavedKey = "kDCAlarmArraySavedKey"

    fileprivate init() {
        alarmArray = DBManager.shareManager().find_all_alarm() as! [DCAlarm]
    }

//    func save() {
//        let alarmArrayData = NSKeyedArchiver.archivedData(withRootObject: alarmArray)
//        kLXMUserDefaults.set(alarmArrayData, forKey: kDCAlarmArraySavedKey)
//        kLXMUserDefaults.synchronize()
//    }
}
