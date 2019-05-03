//
//  String+ZX.swift
//  ZXChartViewTemp
//
//  Created by JuanFelix on 2017/4/27.
//  Copyright © 2017年 screson. All rights reserved.
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
