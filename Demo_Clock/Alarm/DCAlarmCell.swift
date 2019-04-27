//
//  DBManager.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

let DCAlarmCellIdentifier = "DCAlarmCell"
let kDCAlarmCellHeight = 60


class DCAlarmCell: UITableViewCell {

    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var alarmSwith: UISwitch!
    
    fileprivate var alarm: DCAlarm?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configWithAlarm(_ alarm: DCAlarm, indexPath: IndexPath) {
        self.alarm = alarm
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = alarm.alarmDate {
            self.dateLabel.text = dateFormatter.string(from: date as Date)
        }
        
        self.descriptionLabel.text = alarm.descriptionText
        self.alarmSwith.isOn = alarm.alarmOn
    }
    //open and close 
    @IBAction func handleSwitchTapped(_ sender: UISwitch) {
        if let tempAlarm = self.alarm {
            if sender.isOn {
                tempAlarm.turnOnAlarm(alarm_instance: self.alarm!)
                NSLog("turn on alarm")
            } else {
                tempAlarm.turnOffAlarm(alarm_instance: self.alarm!)
                NSLog("turn off alarm")
            }
            
        }
        
        
    }
    func judge_operate(){
        
    }
    
}
