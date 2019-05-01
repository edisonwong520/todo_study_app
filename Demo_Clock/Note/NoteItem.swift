//
//  NoteItem.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class NoteItem: NSObject {
    var createDate: Date?
    var id: Int
    var title: String
    var context: String

    override init() {
        id = -1
        createDate = Date()
        title = ""
        context = ""
    }

    public init(id: Int, createDate: Date, title: String, context: String) {
        //        self.id=id
        self.id = id
        self.title = title
        self.createDate = createDate
        self.context = context
    }
}

// MARK: - PrivateMethod
