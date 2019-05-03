//
//  ScoreItem.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class ScoreItem: NSObject {
    var id: Int
    var title: String
    var score: Float

    override init() {
        id = -1
        title = ""
        score = 0
    }

    public init(id: Int, title: String, score: Float) {
        //        self.id=id
        self.id = id
        self.title = title
        self.score = score
    }
}
