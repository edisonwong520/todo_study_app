//
//  String+ZX.swift
//  ZXChartViewTemp
//
//  Created by JuanFelix on 2017/4/27.
//  Copyright © 2017年 screson. All rights reserved.
//

import Foundation

extension String {
    func index(at: Int) -> Index {
        return self.index(startIndex, offsetBy: at)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(at: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(at: to)
        return substring(to: toIndex)
    }
    
    func substring(with r:Range<Int>) -> String {
        let startIndex  = index(at: r.lowerBound)
        let endIndex    = index(at: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
