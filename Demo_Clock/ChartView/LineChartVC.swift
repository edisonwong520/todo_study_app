//
//  LineChartVC.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//
import Charts
import UIKit
let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenWidth = UIScreen.main.bounds.size.width
var score_list: [ScoreItem] = []
var studytime_list: [StudytimeItem] = []
class LineChartVC: BaseVC {
    var circleColors: [UIColor] = [UIColor]()
    var lineChartView: LineChartView = LineChartView()
    var TimeChartView: LineChartView = LineChartView()
    override func viewDidLoad() {
        super.viewDidLoad()
        // ------first view
        // 添加折线
        addLineChart()
        // 折线图描述文字和样式
        chartDescription()
        // 设置交互样式
        interactionStyle()
        // 修改背景色和边框样式

        setYAxisStyle()
        // 设置限制线（可设置多根）
        setlimitLine()
        // 添加（刷新数据）

        var firstdataEntries = [ChartDataEntry]()
        score_list = DBManager.shareManager().find_all_score()
        for i in 0 ..< score_list.count {
            let entry = ChartDataEntry(x: Double(i), y: Double(score_list[i].score))
            firstdataEntries.append(entry)
            circleColors.append(ZHFColor.blue)
            //            circleColors.append(ZHFColor.blue)
        }
        var seconddataEntries = [ChartDataEntry]()
        studytime_list = DBManager.shareManager().find_all_studytime()
        for i in 0 ..< studytime_list.count {
            let entry = ChartDataEntry(x: Double(i), y: Double(studytime_list[i].studytime))
            seconddataEntries.append(entry)
            circleColors.append(ZHFColor.blue)
            //            circleColors.append(ZHFColor.blue)
        }
        updataData(lineChartView: lineChartView, dataEntries1: firstdataEntries, positiveSuffix: "分", label: "成绩")
        updataData(lineChartView: TimeChartView, dataEntries1: seconddataEntries, positiveSuffix: "小时", label: "时长")

        setBackgroundBorder()
        // 设置x轴的样式属性
        setXAxisStyle()
        // 设置y轴的样式属性
    }
}

// MARK: - UI和折线图基本样式

extension LineChartVC {
    // 添加折线
    func addLineChart() {
        // fisrt
        lineChartView.backgroundColor = ZHFColor.white
        lineChartView.frame.size = CGSize(width: ScreenWidth - 20, height: 280)
        lineChartView.center = CGPoint(x: ScreenWidth / 2, y: 262)
        lineChartView.delegate = self
        // second
        TimeChartView.backgroundColor = ZHFColor.white
        TimeChartView.frame.size = CGSize(width: ScreenWidth - 20, height: 280)
        TimeChartView.center = CGPoint(x: ScreenWidth / 2, y: 580)
        TimeChartView.delegate = self

        view.addSubview(lineChartView)
        view.addSubview(TimeChartView)
        // 刷新按钮响应
        refreshrBtn.addTarget(self, action: #selector(updataData), for: UIControlEvents.touchUpInside)
    }

    // 设置交互样式
    func interactionStyle() {
        lineChartView.scaleYEnabled = false // 取消Y轴缩放
        lineChartView.doubleTapToZoomEnabled = true // 双击缩放
        lineChartView.dragEnabled = true // 启用拖动手势
        lineChartView.dragDecelerationEnabled = true // 拖拽后是否有惯性效果
        lineChartView.dragDecelerationFrictionCoef = 0.9 // 拖拽后惯性效果摩擦系数(0~1)越小惯性越不明显

        TimeChartView.scaleYEnabled = false // 取消Y轴缩放
        TimeChartView.doubleTapToZoomEnabled = true // 双击缩放
        TimeChartView.dragEnabled = true // 启用拖动手势
        TimeChartView.dragDecelerationEnabled = true // 拖拽后是否有惯性效果
        TimeChartView.dragDecelerationFrictionCoef = 0.9 // 拖拽后惯性效果摩擦系数(0~1)越小惯性越不明显
    }

    // 描述文字
    func chartDescription() {
        lineChartView.noDataText = "暂无数据"
        lineChartView.legend.textColor = ZHFColor.purple // 描述文字颜色
        lineChartView.legend.formSize = 10 // （图例大小）默认是8
        lineChartView.legend.form = Legend.Form.circle // 图例头部样式
        // 矩形：.square（默认值） 圆形：.circle   横线：.line  无：.none 空：.empty（与 .none 一样都不显示头部，但不同的是 empty 头部仍然会占一个位置)

        TimeChartView.noDataText = "暂无数据"
        TimeChartView.legend.textColor = ZHFColor.purple // 描述文字颜色
        TimeChartView.legend.formSize = 10 // （图例大小）默认是8
        TimeChartView.legend.form = Legend.Form.circle // 图例头部样式
    }

    // 修改背景色和边框样式
    func setBackgroundBorder() {
        //        lineChartView.drawGridBackgroundEnabled = true  //绘制图形区域背景
        //        lineChartView.gridBackgroundColor = ZHFColor.yellow //背景改成黄色(默认为浅灰色)
        lineChartView.drawBordersEnabled = true // 绘制图形区域边框
        lineChartView.borderColor = ZHFColor.red // 边框为红色
        lineChartView.borderLineWidth = 2 // 边框线条大小为2

        TimeChartView.drawBordersEnabled = true // 绘制图形区域边框
        TimeChartView.borderColor = ZHFColor.red // 边框为红色
        TimeChartView.borderLineWidth = 2 // 边框线条大小为2
    }

    // 设置x轴的样式属性
    func setXAxisStyle() {
        // 轴线宽、颜色、刻度、间隔
        lineChartView.xAxis.axisLineWidth = 2 // x轴宽度
        lineChartView.xAxis.axisLineColor = .black // x轴颜色
        lineChartView.xAxis.axisMinimum = 0 // 最小刻度值
        lineChartView.xAxis.axisMaximum = 10 // 最大刻度值
        lineChartView.xAxis.granularity = 1 // 最小间隔

        // 文字属性
        lineChartView.xAxis.labelPosition = .bottom // x轴上的数字显示在下方（默认显示在上方 .top .bottom .bothSided .topInside .bottomInside）
        lineChartView.xAxis.labelTextColor = .red // 刻度文字颜色
        lineChartView.xAxis.labelFont = .systemFont(ofSize: 10) // 刻度文字大小
        lineChartView.xAxis.labelRotationAngle = 90 // 刻度文字倾斜角度

        // 文字格式
        let formatter = NumberFormatter() // 自定义格式
        formatter.positivePrefix = "" // 数字前缀positivePrefix、 后缀positiveSuffix
        lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
//        自定义刻度标签文字
        var xValues: [String] = []
        for index in 0 ..< score_list.count {
            xValues.append("测验\(index + 1)")
        }

        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)

        // 网格线
        lineChartView.xAxis.drawGridLinesEnabled = true // 制网格线
        lineChartView.xAxis.gridColor = .orange // x轴对应网格线的颜色
        lineChartView.xAxis.gridLineWidth = 2 // x轴对应网格线的大小
        lineChartView.xAxis.gridLineDashLengths = [4, 2] // 虚线各段长度

        // -------second view

        TimeChartView.xAxis.axisLineWidth = 2 // x轴宽度
        TimeChartView.xAxis.axisLineColor = .black // x轴颜色
        TimeChartView.xAxis.axisMinimum = 0 // 最小刻度值
        TimeChartView.xAxis.axisMaximum = 10 // 最大刻度值
        TimeChartView.xAxis.granularity = 1 // 最小间隔

        // 文字属性
        TimeChartView.xAxis.labelPosition = .bottom // x轴上的数字显示在下方（默认显示在上方 .top .bottom .bothSided .topInside .bottomInside）
        TimeChartView.xAxis.labelTextColor = .red // 刻度文字颜色
        TimeChartView.xAxis.labelFont = .systemFont(ofSize: 10) // 刻度文字大小
        TimeChartView.xAxis.labelRotationAngle = 90 // 刻度文字倾斜角度

        TimeChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        //        自定义刻度标签文字
        xValues = []
        for index in 0 ..< studytime_list.count {
            xValues.append("\(studytime_list[index].date)")
        }

        TimeChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)

        // 网格线
        TimeChartView.xAxis.drawGridLinesEnabled = true // 制网格线
        TimeChartView.xAxis.gridColor = .orange // x轴对应网格线的颜色
        TimeChartView.xAxis.gridLineWidth = 2 // x轴对应网格线的大小
        TimeChartView.xAxis.gridLineDashLengths = [4, 2] // 虚线各段长度
    }

    // 设置y轴的样式属性(分左、右侧)
    func setYAxisStyle() {
        lineChartView.leftAxis.drawZeroLineEnabled = true // 绘制0刻度线
        lineChartView.leftAxis.zeroLineColor = .red // 0刻度线颜色
        lineChartView.leftAxis.zeroLineWidth = 2 // 0刻度线线宽
        lineChartView.leftAxis.zeroLineDashLengths = [4, 2] // 0刻度线使用虚线样式
        // （1.轴线宽、颜色、刻度、间隔 2.文字属性 3.文字格式、4.网格线）和 func setXAxisStyle()方法一样
        TimeChartView.leftAxis.drawZeroLineEnabled = true // 绘制0刻度线
        TimeChartView.leftAxis.zeroLineColor = .red // 0刻度线颜色
        TimeChartView.leftAxis.zeroLineWidth = 2 // 0刻度线线宽
        TimeChartView.leftAxis.zeroLineDashLengths = [4, 2] // 0刻度线使用虚线样式
    }

    // 设置限制线（可设置多根）
    func setlimitLine() {
        // 界限1
        let limitLine1 = ChartLimitLine(limit: 85, label: "优秀")

        limitLine1.lineColor = ZHFColor.green
        limitLine1.lineWidth = 2 // 线宽
        limitLine1.lineDashLengths = [4, 2] // 虚线样式
        // limitLine1.drawLabelEnabled = false //不绘制文字
        limitLine1.valueTextColor = UIColor.blue // 文字颜色
        limitLine1.valueFont = UIFont.systemFont(ofSize: 13) // 文字大小
        limitLine1.labelPosition = .leftTop // 文字位置
        /* .leftTop：左上
         .leftBottom：左下
         .rightTop：右上（默认）
         .rightBottom：右下
         */
        lineChartView.leftAxis.addLimitLine(limitLine1)

        // 界限2
        let limitLine2 = ChartLimitLine(limit: 60, label: "合格")
        limitLine1.lineColor = ZHFColor.purple
        lineChartView.leftAxis.addLimitLine(limitLine2)
        lineChartView.leftAxis.drawLimitLinesBehindDataEnabled = true // 将限制线绘制在折线后面
    }
}

// MARK: -    数据加载和刷新

extension LineChartVC {
    @objc func updataData(lineChartView: LineChartView, dataEntries1: [ChartDataEntry], positiveSuffix: String, label: String) {
        // 设置折线
        let chartDataSet1 = LineChartDataSet(values: dataEntries1, label: label)
        chartDataSet1.setColors(ZHFColor.zhf_randomColor(), ZHFColor.zhf_randomColor()) // 设置折线颜色(是一个循环，例如：
        chartDataSet1.lineWidth = 3 // 线条宽度
        chartDataSet1.lineDashLengths = [4, 2] // 设置折线为虚线各段长度
        chartDataSet1.mode = .horizontalBezier // 贝塞尔曲线（默认是折线 .linear .stepped .cubicBezier .horizontalBezier）

        chartDataSet1.circleColors = circleColors // 外圆颜色
        chartDataSet1.circleHoleColor = ZHFColor.yellow // 内圆颜色
        chartDataSet1.circleRadius = 6 // 外圆半径
        chartDataSet1.circleHoleRadius = 4 // 内圆半径
        // 设置折线上的文字
        chartDataSet1.drawValuesEnabled = true // 绘制拐点上的文字(默认绘制)
        chartDataSet1.valueColors = [.blue] // 拐点上的文字颜色
        chartDataSet1.valueFont = .systemFont(ofSize: 9) // 拐点上的文字大小
        // 文字格式
        let formatter = NumberFormatter() // 自定义格式
        formatter.positiveSuffix = positiveSuffix // 数字后缀单位
        chartDataSet1.valueFormatter = DefaultValueFormatter(formatter: formatter)
        // 绘制填充色背景
        // *半透明的填充色
        chartDataSet1.drawFilledEnabled = true // 开启填充色绘制
        chartDataSet1.fillColor = .orange // 设置填充色
        chartDataSet1.fillAlpha = 0.5 // 设置填充色透明度
        // *渐变色填充
        // 开启填充色绘制
        chartDataSet1.drawFilledEnabled = true
        // 渐变颜色数组
        let gradientColors = [UIColor.orange.cgColor, UIColor.white.cgColor] as CFArray
        // 每组颜色所在位置（范围0~1)
        let colorLocations: [CGFloat] = [1.0, 0.0]
        // 生成渐变色
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: gradientColors, locations: colorLocations)
        // 将渐变色作为填充对象s
        chartDataSet1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)

        let chartData = LineChartData(dataSets: [chartDataSet1])
        // 设置折现图数据
        lineChartView.data = chartData
        lineChartView.animate(xAxisDuration: 2) // 展示方式xAxisDuration 和 yAxisDuration两种
    }
}

// MARK: -   ChartViewDelegate

extension LineChartVC: ChartViewDelegate {
    // 1.点击选中
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("点击选中")
        // 将选中的数据点的颜色改成黄色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let values = chartDataSet.values
        let index = values.index(where: { $0.x == highlight.x }) // 获取索引
        chartDataSet.circleColors = circleColors // 还原
        chartDataSet.circleColors[index!] = .orange

        // 重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
//         //显示该点的MarkerView标签(不同形式)
        // self.showMarkerView(value: "\(entry.y)")
        showBalloonMarkerView(value: "\(entry.y)")
    }

    // 2.没有选中
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("取消选中")
        // 还原所有点的颜色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        chartDataSet.circleColors = circleColors

        // 重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }

    // 3.捏合放大或缩小
    func chartScaled(_: ChartViewBase, scaleX _: CGFloat, scaleY _: CGFloat) {
        NSLog("捏合放大或缩小")
    }

    // 4.拖拽图表
    func chartTranslated(_: ChartViewBase, dX _: CGFloat, dY _: CGFloat) {
        NSLog("拖拽图表")
    }
}

// MARK: -   MarkerView标签

extension LineChartVC {
    // 显示MarkerView标签
    func showMarkerView(value: String) {
        let marker = MarkerView(frame: CGRect(x: 20, y: 20, width: 80, height: 20))
        marker.chartView = lineChartView
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        label.text = "\(value)"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        marker.addSubview(label)
        lineChartView.marker = marker
    }

    // 显示BalloonMarkerView标签
    func showBalloonMarkerView(value: String) {
        let marker = BalloonMarker(color: UIColor(white: 180 / 255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = lineChartView
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        marker.setLabel("\(value)")
        lineChartView.marker = marker
    }
}
