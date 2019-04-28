//
//  DCAlarm.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class DCAlarm: NSObject {
    var alarmDate: Date?
    var descriptionText: String
    var identifier: String
    var selectedDay: Int
    var alarmOn: Bool
    var id: Int

    override init() {
        id = -1
        identifier = ""
        alarmDate = Date()
        descriptionText = ""
        selectedDay = 0
        alarmOn = true
    }

    public init(id: Int, alarmDate: Date, descriptionText: String, identifier: String, selectedDay: Int, alarmOn: Bool) {
        //        self.id=id
        self.id = id
        self.identifier = identifier
        self.alarmDate = alarmDate
        self.descriptionText = descriptionText
        self.selectedDay = selectedDay
        self.alarmOn = alarmOn
    }

    func getWeekday() -> Int {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: Date())

        let dayweek = Int(comps.weekday! - 1)
        var re = 1
        if dayweek == 0 {
            re = 64
        } else {
            for _ in 1 ..< dayweek {
                re = re * 2
            }
        }
        return re
    }

    func turnOnAlarm(alarm_instance: DCAlarm) {
//        if alarm_instance.alarmOn == true {
//            return
//        }

        let sql = "UPDATE TodoDB SET alarmOn=1 WHERE id=\(alarm_instance.id)"
        let flagbool = DBManager.shareManager().execute_sql(sql: sql)
        if flagbool {
            NSLog("open alarm from db success")
        } else {
            NSLog("open alarm from db failed")
        }

        if alarm_instance.selectedDay == 0 {
            alarm_instance.selectedDay = getWeekday()
        }

        NSLog("alarm_instance.selectedDay is \(alarm_instance.selectedDay)")
        NSLog("alarm_instance.alarmDate is \(alarm_instance.alarmDate)")

        for i in 1 ... 7 {
            if ((1 << (i - 1)) & alarm_instance.selectedDay) != 0 {
                addLocalNotificationForDate(alarm_instance.alarmDate!, selectedDay: i, alarm_instance: alarm_instance)
            }
        }

        alarmOn = true

        NSLog("after set localNotification is \n \(UIApplication.shared.scheduledLocalNotifications)")
    }

    func turnOffAlarm(alarm_instance: DCAlarm) {
//        if alarm_instance.alarmOn == false {
//            return
//        }
        alarm_instance.alarmOn = false
        let sql = "UPDATE TodoDB SET alarmOn=0 WHERE id=\(alarm_instance.id)"
        let flagbool = DBManager.shareManager().execute_sql(sql: sql)
        if flagbool {
            NSLog("cancel alarm from db success")
        } else {
            NSLog("cancel alarm from db failed")
        }

        if let tempArray = UIApplication.shared.scheduledLocalNotifications {
            for tempNotification in tempArray {
//                NSLog("it is \(tempNotification.userInfo!["identifier"])")
                if let identfier = tempNotification.userInfo!["identifier"] as? String {
                    if identfier == identifier {
                        UIApplication.shared.cancelLocalNotification(tempNotification)
                    }
                }
            }
        }
        NSLog("after set localNotification is \n \(UIApplication.shared.scheduledLocalNotifications)")
    }
}

// MARK: - PrivateMethod

fileprivate extension DCAlarm {
    fileprivate func addLocalNotificationForDate(_ date: Date, selectedDay: NSInteger, alarm_instance: DCAlarm) {
        // selectedDay == 0则认为是只响一次的闹钟
        let calendar = Calendar.current
        let type: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday]
        var dateComponents = (calendar as NSCalendar).components(type, from: date)
        dateComponents.second = 0
        let newDate = calendar.date(from: dateComponents)
        var diffComponents = DateComponents()
        var newWeekDay = selectedDay + 1 // 苹果默认周日是1，依次往后排；而app里定义的是周一是1，依次往后排
        if newWeekDay == 8 {
            newWeekDay = 1
        }
        diffComponents.day = newWeekDay - dateComponents.weekday! // 计算出所选的周几与当前时间的间隔
        let fireDate = (calendar as NSCalendar).date(byAdding: diffComponents, to: newDate!, options: .wrapComponents)
        let localNotification = UILocalNotification()
        localNotification.fireDate = fireDate
        let repeateInterval: NSCalendar.Unit = [.NSWeekCalendarUnit] // 注意这个选项才是每周。。。
        localNotification.repeatInterval = selectedDay == 0 ? NSCalendar.Unit(rawValue: 0) : repeateInterval
        localNotification.timeZone = TimeZone.current
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "本地推送内容"

        let title = DBManager.shareManager().get_value_byid(find: "title", id: alarm_instance.id)
        localNotification.userInfo = [
            "identifier": self.identifier, // 注意，这里不同日子同一时刻的通知公用一个identifier
            "fireDay": fireDate!,
            "title": title,
        ]
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
}
