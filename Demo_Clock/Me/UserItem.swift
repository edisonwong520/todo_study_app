
//
//  user.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import Foundation

class UserItem: NSObject {
    
    var id: Int
    var realname: String
    var name:String
    var password: String
    var email:String
    
    override init() {
        id = -1
        password = ""
        realname = ""
        name = ""
        email = ""
    }
    
    public init(id: Int, realname: String, name: String, password: String,email:String) {
        //        self.id=id
        self.id = id
        self.realname = realname
        self.name = name
        self.password = password
        self.email = email
    }
}
