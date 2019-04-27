//
//  DCClockSettingViewController.swift
//  Demo_Clock
//
//  Created by luxiaoming on 16/1/20.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

import UIKit

class DCClockSettingViewController: LXMBaseViewController {
    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var confirmButton: UIButton!

    // button的tag为1-7，在xib中设置
    @IBOutlet var mondayButton: UIButton!

    @IBOutlet var tuesdayButton: UIButton!

    @IBOutlet var wednesdayButton: UIButton!

    @IBOutlet var thursdayButton: UIButton!

    @IBOutlet var fridayButton: UIButton!

    @IBOutlet var saturdayButton: UIButton!

    @IBOutlet var sundayButton: UIButton!

    fileprivate var isAddingAlarm: Bool = false

    fileprivate var targetAlarm: DCAlarm!

    fileprivate var buttonArray: [UIButton] {
        return [mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton, sundayButton]
    }

    /// 从右向左依次是1-7，每一位表示一个button有没有选中，0x1111111表示全选，0x0000000表示一个都没选
    var selectedButtonTag = 0

    class func loadFromStroyboardWithTargetAlarm(_ alarm: DCAlarm?) -> DCClockSettingViewController {
        let viewController = DCClockSettingViewController.swift_loadFromStoryboard("Main")
        if alarm == nil {
            viewController.isAddingAlarm = true
            viewController.targetAlarm = DCAlarm()
        } else {
            viewController.isAddingAlarm = false
            viewController.targetAlarm = alarm
        }
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isAddingAlarm {
            title = "添加闹钟"
        } else {
            title = "修改闹钟"
        }

        test()

        setupDefault()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - PrivateMethod

extension DCClockSettingViewController {
    func test() {
        let version = kLXMSystemVersion
        NSLog("version is \(version)")
    }

    func setupDefault() {
        if let alarm = self.targetAlarm {
            if let date = alarm.alarmDate {
                datePicker.date = date as Date
            } else {
                datePicker.date = Date()
            }
            selectedButtonTag = alarm.selectedDay
            for button in buttonArray {
                let selected = 1 << (button.tag - 1)
                button.isSelected = (alarm.selectedDay & selected) != 0
            }
        }
    }
}

// MARK: - Action

extension DCClockSettingViewController {
    @IBAction func handleCancelButtonTapped(_: UIButton) {
        dismiss(animated: true) { () -> Void in
        }
    }

    @IBAction func handleConfirmButtonTapped(_: UIButton) {
        if let alarm = self.targetAlarm {
            alarm.alarmDate = datePicker.date
            alarm.selectedDay = selectedButtonTag
            alarm.descriptionText = String(format: "%02x", selectedButtonTag)
            alarm.alarmOn = false
            alarm.identifier = alarm.alarmDate?.description
            if isAddingAlarm {
                DCAlarmManager.sharedInstance.alarmArray.append(alarm)
            }

            DCAlarmManager.sharedInstance.save()

            handleCancelButtonTapped(UIButton())
        } else {
            NSLog("there is something wrong, 理论上alarm不会为空的")
        }
    }

    @IBAction func handleDayButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var resultTag = 0x0
        for button in buttonArray {
            let selected: Int = button.isSelected ? 1 : 0
            let tag = selected << (button.tag - 1)
            resultTag = resultTag | tag
        }
        selectedButtonTag = resultTag

        let aaa = String(format: "%02x", resultTag)
        NSLog("self.selectedButtonTag is \(aaa)")
    }
}
