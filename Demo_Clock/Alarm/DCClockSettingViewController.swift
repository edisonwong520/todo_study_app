//
//  DCClockSettingViewController.swift
//  Demo_Clock
//
//  Created by luxiaoming on 16/1/20.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

import UIKit

class DCClockSettingViewController: LXMBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var todoTitleLabel: UITextField!
    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var confirmButton: UIButton!

    @IBOutlet var priorityPicker: UIPickerView!
    @IBOutlet var todoNote: UITextView!
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
    var priority_count = 1
    var priority_array = ["最高", "重要", "一般", "不重要"]
    //    var priority_dict:[String:Int] = ["最高":1,"重要":2,"一般":3,"不重要":4]
    var priority_index = 3

    // overwrite
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return priority_array.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return priority_array[row]
    }

    var todo: ToDoItem?

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " Please input note..."
            textView.textColor = UIColor.lightGray
        }
    }

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
        priorityPicker.delegate = self
        priorityPicker.dataSource = self

        todoNote.delegate = self

        todoNote.text = " Please input note..."
        todoNote.textColor = UIColor.lightGray

        let borderGray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        todoNote.layer.borderColor = borderGray.cgColor
        todoNote.layer.borderWidth = 0.5
        todoNote.layer.cornerRadius = 5

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

    func get_b_repeatday(repeatday: Int) -> String {
        var repeatday1 = repeatday
        var re = ""
        for _ in 1 ... 7 {
            if repeatday1 % 2 == 0 {
                re += "0"
            } else {
                re += "1"
            }
            repeatday1 /= 2
        }
        return re
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
            NSLog("there is something wrong")
        }

        // add todo item------------------------
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let todo = todo {
            var strDate = dateFormatter.string(from: todo.date as Date)
            let current_index = DBManager.shareManager().find_id(date: strDate, title: todo.title)

            todo.date = datePicker.date
            todo.note = todoNote.text!
            todo.priority = priorityPicker.selectedRow(inComponent: 0) + 1
            strDate = dateFormatter.string(from: todo.date as Date)

            let sql = "UPDATE TodoDB SET title='\(todo.title)',date='\(strDate)',note='\(todo.note)',priority=\(todo.priority) ,repeatday='\(todo.repeatday)' WHERE id=\(current_index);"
            NSLog(sql)
            let flag_bool = DBManager.shareManager().execute_sql(sql: sql)
            if !flag_bool {
                NSLog("update error")
            }

        } else {
            //tag

            let str_repeatday = get_b_repeatday(repeatday: selectedButtonTag)

            priority_index = priorityPicker.selectedRow(inComponent: 0) + 1
            todo = ToDoItem(title: todoTitleLabel.text!, note: todoNote.text, date: datePicker.date, priority: priority_index, repeatday: str_repeatday)

            todos_list.append(todo!)
            DBManager.shareManager().insert(todoitem: todo!)

            //                self.handleCancelButtonTapped(UIButton())
        }

        _ = navigationController?.popToRootViewController(animated: true)
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
