//
//  NoteCell.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

let NoteCellIdentifier = "NoteCell"
let kTDAlarmCellHeight = 60

class NoteCell: UITableViewCell {
    @IBOutlet var title: UILabel!

    @IBOutlet var datelabel: UILabel!

    fileprivate var note: NoteItem?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func judge_operate() {}

    func configWithNote(_ note: NoteItem, indexPath _: IndexPath) {
        self.note = note
        title.text = note.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        datelabel.text = dateFormatter.string(from: note.createDate as! Date)
    }
}
