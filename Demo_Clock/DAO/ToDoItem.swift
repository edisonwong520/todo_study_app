//
//  ToDoItem.h
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation

public class ToDoItem: NSObject {
//    var id:Int
    var title: String
    var note: String
    var date: Date
    var priority: Int
    var repeatday: String

    public init(title: String, note: String, date: Date, priority: Int, repeatday: String) {
//        self.id=id
        self.title = title
        self.note = note
        self.date = date
        self.priority = priority
        self.repeatday = repeatday
    }

    public override init() {
        // get now
        let now = Date()

//        self.id=9999
        title = ""
        note = ""
        date = now
        priority = 3
        repeatday = "0"
    }
}
