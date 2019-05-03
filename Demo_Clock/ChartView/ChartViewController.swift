//
//  ViewController.swift
//  ZXChartViewTemp
//
//  Created by JuanFelix on 2017/4/27.
//  Copyright © 2017年 screson. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    var lineChartView:ZXLineChartView!
    var TimeChartView:ZXLineChartView!
    var data_list:[ScoreItem] = []
    var values:[NSNumber] = []
//    var values = [NSNumber.init(value: 20),NSNumber.init(value: 130),NSNumber.init(value: 22.5)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        data_list = DBManager.shareManager().find_all_score()
        for score_item in data_list{
            values.append(NSNumber.init(value:score_item.score))
        }
        lineChartView = ZXLineChartView.init(CGPoint(x:0,y:135))
        lineChartView.selectedPoint(at: 2)
        lineChartView.delegate = self
        lineChartView.dataSource = self
        self.view.addSubview(lineChartView)
        
//        TimeChartView = ZXLineChartView.init(CGPoint(x:0,y:450))
//        TimeChartView.selectedPoint(at: 2)
//        TimeChartView.delegate = self
//        TimeChartView.dataSource = self
//        self.view.addSubview(TimeChartView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        values.append(NSNumber.init(value: arc4random() % 60))
        lineChartView.reloadData()
    }
    
}

extension ChartViewController:ZXLineChartViewDelegate {
    func zxLineChartView(_ lineChartView: ZXLineChartView, selectedAt index: Int) {
        print("selected:\(index)")
    }
    
    func zxLineChartView(_ lineChartView: ZXLineChartView, animation finished: Bool) {
        print("line animiation finished")
    }
}

extension ChartViewController:ZXLineChartViewDataSource {
    func numberOfValues(in lineChartView: ZXLineChartView) -> Int {
        return values.count
    }
    
    func zxLineChartView(_ lineChartView: ZXLineChartView, valueAt index: Int) -> NSNumber {
        return values[index]
    }
    
    //present the label on the axis x
    func zxLineChartView(_ lineChartView: ZXLineChartView, titleAt index: Int) -> String {
        return "\(data_list[index].title)"
    }
    /*
     func preValue(in lineChartView: ZXLineChartView) -> NSNumber? {
     //return NSNumber.init(value: 45)
     return nil
     }
     func lastValue(in lineChartView: ZXLineChartView) -> NSNumber? {
     //return NSNumber.init(value: 30)
     return nil
     }
     */
}

