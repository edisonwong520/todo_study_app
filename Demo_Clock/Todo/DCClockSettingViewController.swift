//
//  DCClockSettingViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit
import RichEditorView
class DCClockSettingViewController: LXMBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var editorView: RichEditorView!
    
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
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
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
        
        editorView.delegate = self as? RichEditorDelegate
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        
        toolbar.delegate = self
        toolbar.editor = editorView
        
        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }
        
        var options = toolbar.options
        options.append(item)
        toolbar.options = options
    
        
        //----
        selectedButtonTag = getWeekday()
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
            title = "添加"
        } else {
            title = "修改"
        }
        
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
    
    func getWeekday() -> Int {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: Date())
        
        let dayweek = Int(comps.weekday! - 1)
        var re = 1
        if dayweek == 0 {
            re = 1
        } else {
            for _ in 1 ..< dayweek {
                re = re * 2
            }
        }
        return re
    }
    
    public func show_conflict(date: String) -> String {
        var confict = [Int]()
        confict = DBManager.shareManager().find_confilt(strdate: date)
        
        if confict.count == 0 {
            return ""
        } else {
            var title_list = [String]()
            for id in confict {
                title_list.append("'" + DBManager.shareManager().get_value_byid(find: "title", id: id) + "'")
            }
            let context = title_list.joined(separator: ",")
            
            return context
        }
    }
    
    //    public func date_confilt_alarm(date:String) -> Bool{
    //        let date_list = DBManager.shareManager().find_confilt(strdate: date)
    //        if date_list.count==0{
    //            return false
    //        }else{
    ////            let sql = "SELECT title FROM TodoDB WHERE date='\(date)';"
    ////            let title_list = DBManager.shareManager().get_result_by_sql(sql: sql)
    //            var title_list = [String]()
    //            for id in date_list{
    //                title_list.append("'"+DBManager.shareManager().get_value_byid(find: "title", id: id)+"'")
    //            }
    //            let context = title_list.joined(separator: ",")
    //            let alert = UIAlertView(title: "提醒", message: "您设定的 " + context + " 时间冲突了", delegate: nil, cancelButtonTitle: "OK")
    //            alert.show()
    //            return true
    //        }
    //    }
}

// MARK: - PrivateMethod

// ---

extension DCClockSettingViewController {
    //    func test() {
    //        let version = kLXMSystemVersion
    //        NSLog("version is \(version)")
    //    }
    
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

// ----
extension DCClockSettingViewController {
    @IBAction func handleCancelButtonTapped(_: UIButton) {
        dismiss(animated: true) { () -> Void in
        }
    }
    
    @IBAction func handleConfirmButtonTapped(_: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let conflict_context = show_conflict(date: dateFormatter.string(from: datePicker.date))
        
        // find conlict and show
        if conflict_context != "" {
            let alert = UIAlertView(title: "提醒", message: "当前设定时间与之前的 " + conflict_context + " 时间冲突了", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        // add todo item------------------------
        if let todo = todo {
            todo.date = datePicker.date
            var strDate = dateFormatter.string(from: todo.date as Date)
            let current_index = DBManager.shareManager().find_id(date: strDate, title: todo.title)
            
            todo.note = todoNote.text!
            todo.priority = priorityPicker.selectedRow(inComponent: 0) + 1
            strDate = dateFormatter.string(from: todo.date as Date)
            
            // update todoitem
            var sql = "UPDATE TodoDB SET title='\(todo.title)',date='\(strDate)',note='\(todo.note)',priority=\(todo.priority) ,repeatday='\(todo.repeatday)' WHERE id=\(current_index);"
            NSLog("update todoitem" + sql)
            var flag_bool = DBManager.shareManager().execute_sql(sql: sql)
            if !flag_bool {
                NSLog("update todoitem error")
            }
            
            // update alarm error
            let str_repeatday = get_b_repeatday(repeatday: selectedButtonTag)
            sql = "UPDATE TodoDB SET date='\(strDate)',repeatday='\(str_repeatday)' WHERE id=\(current_index);"
            NSLog("update alarm" + sql)
            flag_bool = DBManager.shareManager().execute_sql(sql: sql)
            if !flag_bool {
                NSLog("update alarm error")
            }
            
        } else {
            //tag
            
            let str_repeatday = get_b_repeatday(repeatday: selectedButtonTag)
            
            priority_index = priorityPicker.selectedRow(inComponent: 0) + 1
            todo = ToDoItem(title: todoTitleLabel.text!, note: todoNote.text, date: datePicker.date, priority: priority_index, repeatday: str_repeatday, alarmOn: true)
            
            todos_list.append(todo!)
            DBManager.shareManager().insert(todoitem: todo!)
            
            // add alarm
            let alarm = DCAlarm()
            alarm.alarmDate = datePicker.date
            alarm.selectedDay = selectedButtonTag
            alarm.descriptionText = String(format: "%02x", selectedButtonTag)
            alarm.alarmOn = true
            alarm.identifier = dateFormatter.string(from: todo!.date as Date)
            
            let current_id = DBManager.shareManager().find_id(date: alarm.identifier, title: (todo?.title)!)
            alarm.id = Int(current_id)
            DCAlarmManager.sharedInstance.alarmArray.append(alarm)
            NSLog("start to turn on alarm first time")
            let temp = alarm
            temp.turnOnAlarm(alarm_instance: alarm)
        }
        handleCancelButtonTapped(UIButton())
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
        
        //        let aaa = String(format: "%02x", resultTag)
        //        NSLog("self.selectedButtonTag is \(aaa)")
    }
}


extension DCClockSettingViewController: RichEditorToolbarDelegate {
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
    
}
