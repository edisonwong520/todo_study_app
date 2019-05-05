//
//  StudytimeItem.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/5.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation
class StudytimeItem: NSObject {
    var date: String
    var studytime: Float
    var userid:Int
    override init() {
        userid = -1
        date = ""
        studytime = 0
    }
    
    public init(userid:Int,date: String, studytime: Float) {
        //        self.id=id
        self.userid = userid
        self.date = date
        self.studytime = studytime
    }
}
