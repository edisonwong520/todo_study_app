//
//  ZXLineChartView.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

protocol ZXLineChartViewDelegate:class {
    func zxLineChartView(_ lineChartView:ZXLineChartView,selectedAt index:Int)
    func zxLineChartView(_ lineChartView:ZXLineChartView,animation finished:Bool)
}

extension ZXLineChartViewDelegate {
    func zxLineChartView(_ lineChartView:ZXLineChartView,selectedAt index:Int){}
    func zxLineChartView(_ lineChartView:ZXLineChartView,animation finished:Bool){}
}

protocol ZXLineChartViewDataSource:class {
    func numberOfValues(in lineChartView:ZXLineChartView) -> Int
    func zxLineChartView(_ lineChartView:ZXLineChartView,titleAt index:Int) -> String
    func zxLineChartView(_ lineChartView:ZXLineChartView,valueAt index:Int) -> NSNumber
    /*起始点 默认： 0 0*/
    func preValue(in lineChartView:ZXLineChartView) -> NSNumber?
    /*终止点 默认：根据values中最后两点趋势计算*/
    func lastValue(in lineChartView:ZXLineChartView) -> NSNumber?
}

extension ZXLineChartViewDataSource {
    func preValue(in lineChartView:ZXLineChartView) -> NSNumber? {
        return nil
    }
    
    func lastValue(in lineChartView:ZXLineChartView) -> NSNumber? {
        return nil
    }
}

class ZXLineChartView: UIView {
    weak var delegate:ZXLineChartViewDelegate?
    weak var dataSource:ZXLineChartViewDataSource?
    
    fileprivate var values = [NSNumber]()//要显示的点值
    
    fileprivate var days = [String]()//要显示的时间
    
    
    fileprivate var preValue: NSNumber? //起始点值,绘图时默认 X = 0，Y值0
    fileprivate var lastValue: NSNumber?  //终点值,绘图时默认 X = WIDTH，Y = values中最后两点平均值
    //选中点
    fileprivate var highLightedIndex:Int = 0
    fileprivate var isAnimationFinished:Bool = false
    //
    fileprivate var maxYValue: Int   = 0//Y轴最大值（4的倍数，并且最接近values中最大值）
    fileprivate var floatMaxY: Float = 0//Y轴最大浮点值（maxYValue 小于等于1时候，Y轴 用小数呈现）
    fileprivate var lineMargin:CGFloat {//起止点 距屏幕边距
        get {
            if values.count > 0 {
                return ZXLineChartConstant.width / CGFloat(values.count) / 2
            }
            return 30
        }
    }
    fileprivate var spaceRatio:CGFloat {//前后两点间距 与中间值间距不相等，算出的 前后两点Y坐标 需要调整
        get {
            if values.count > 0 {
                return lineMargin / (ZXLineChartConstant.width / CGFloat(values.count))
            }
            return 1.0
        }
    }
    //
    fileprivate var xLabels = [UILabel]()
    fileprivate var yLabels = [UILabel]()
    fileprivate var pointValues: Array<NSValue> {//所有的点值
        get {
            var points = [NSValue]()
            if values.count > 0 {
                for (index,value) in values.enumerated() {
                    points.append(NSValue.init(cgPoint: pointValue(value, index: index)))
                }
            }
            return points
        }
    }
    fileprivate var linePointValues:Array<NSValue> {//轨迹线上的点,比values 多前后两个点
        get {
            var points = pointValues
            points.insert(prePoint(), at: 0)
            points.append(lastPoint())
            return points
        }
    }
    
    fileprivate var maskLayerPointsValue:Array<NSValue> {//填充轨迹(包括左下角，右下角)
        get {
            var points = linePointValues
            points.insert(NSValue.init(cgPoint: CGPoint(x: 0, y: ZXLineChartConstant.chartHeight)), at: 0)
            points.append(NSValue.init(cgPoint: CGPoint(x: ZXLineChartConstant.width, y: ZXLineChartConstant.chartHeight)))
            return points
        }
    }
    //点击点时，弹出显示值
    fileprivate var popView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = ZXLineChartConstant.lineColor
        return view
    }()
    fileprivate var popLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    
    
    init(_ origin:CGPoint) {
        values = []
        days = []
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: ZXLineChartConstant.width, height: ZXLineChartConstant.height))
        self.backgroundColor = ZXLineChartConstant.backgroundColor
        self.clipsToBounds = false
        //Add Layer
        self.chartContentLayer.addSublayer(self.chartFillColorLayer)
        self.chartFillColorLayer.mask = self.chartFillColorMaskLayer
        
        self.chartContentLayer.addSublayer(self.lineLayer)
        self.chartContentLayer.addSublayer(self.dotsContentLayer)
        //Set Mask
        self.animationMaskLayer.addSublayer(self.animationLayer)
        self.chartContentLayer.mask = self.animationMaskLayer
        //Add To Super
        self.layer.addSublayer(self.chartContentLayer)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        self.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 分割线
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor(red: 215 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 0.5).cgColor)
        context?.setShouldAntialias(false)
        context?.setLineWidth(0.5)
        for i in 0..<4 {
            context?.move(to: CGPoint(x: 0, y: ZXLineChartConstant.chartHeight / 4.0 * CGFloat(i) + 0.5))
            context?.addLine(to: CGPoint(x: ZXLineChartConstant.width, y: ZXLineChartConstant.chartHeight / 4.0 * CGFloat(i)))
        }
        context?.strokePath()
        
    }
    //MARK: -
    //MARK: - 绘图背景层 由于动画
    fileprivate var chartContentLayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: ZXLineChartConstant.width, height: ZXLineChartConstant.height)
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    //MARK: - 折线图层
    fileprivate var chartFillColorLayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: ZXLineChartConstant.width, height: ZXLineChartConstant.height)
        layer.backgroundColor = ZXLineChartConstant.maskColor.cgColor
        return layer
    }()
    //MARK: - 用于裁剪折线图背景(填充区域背景)
    fileprivate var chartFillColorMaskLayer = CAShapeLayer()
    //MARK: - 折线图路径
    fileprivate var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1.0
        layer.strokeColor = ZXLineChartConstant.lineColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    //MARK: - animation layer
    fileprivate var animationMaskLayer = CAShapeLayer()
    fileprivate var animationLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath.init(rect: CGRect(x: 0, y: 0, width: ZXLineChartConstant.width, height: ZXLineChartConstant.height)).cgPath
        layer.position = CGPoint(x: -ZXLineChartConstant.width, y: 0)
        return layer
    }()
    
    //MARK: - 承载所有的点图层
    fileprivate var dotsContentLayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: ZXLineChartConstant.width, height: ZXLineChartConstant.height)
        layer.opacity = 0
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    //MARK: - 所有点
    fileprivate var dotLayers:Array<CAShapeLayer> {
        get{
            var layers = [CAShapeLayer]()
            if let dots = dotsContentLayer.sublayers {
                for dot in dots {
                    dot.removeFromSuperlayer()
                }
            }
            for point in pointValues {
                let value = point.cgPointValue
                let dotLayer = CAShapeLayer()
                dotLayer.lineWidth = 1
                dotLayer.strokeColor = ZXLineChartConstant.lineColor.cgColor
                dotLayer.fillColor = UIColor.white.cgColor
                let path = UIBezierPath(arcCenter: value, radius: 3, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
                dotLayer.path = path.cgPath
                dotsContentLayer.addSublayer(dotLayer)
                layers.append(dotLayer)
            }
            return layers
        }
    }
}

//绘制shapelayer label
extension ZXLineChartView {
    fileprivate func buildYLabels() {
        if yLabels.count > 0 {
            for label in yLabels {
                label.removeFromSuperview()
            }
            yLabels.removeAll()
        }
        let max = self.maxY()
        
        for count in (1..<5).reversed() {
            let label = UILabel.init(frame: CGRect(x: 14, y: (ZXLineChartConstant.chartHeight / 4) * CGFloat(4 - count), width: 200, height: 22))
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .left
            label.textColor = UIColor.lightGray
            label.backgroundColor = UIColor.clear
            var str = ""
            if max <= 1 {
                if floatMaxY > 0 {
                    let tempF = self.maxYLess1FloatValue(floatMaxY)
                    str = String(format: "%0.2f", Float(count) * (tempF / 4.0))
                    if tempF < 0.1 {
                        str = String(format: "%0.3f", Float(count) * (tempF / 4.0))
                        if str.characters.count > 0 {
                            let strMxF = String(format: "%0.3f", tempF)
                            let trailZero = strMxF.substring(with: (strMxF.characters.count - 1)..<(strMxF.characters.count))
                            if Int(trailZero) == 0 {
                                let tempV = strMxF.substring(with: 2..<(strMxF.characters.count))
                                let value = Int(tempV) ?? 0
                                if value % 4 == 0 {
                                    str = String(format: "%0.2f", Float(count) * (tempF / 4.0))
                                }
                            }
                        }
                    }
                }else {
                    str = String(format: "%0.2f", Float(count) * (1.0 / 4.0))
                }
            }else{
                str = "\(count * (max / 4))"
            }
            label.text = str
            self.addSubview(label)
            yLabels.append(label)
        }
    }
    
    fileprivate func buildXLables() {
        if xLabels.count > 0 {
            for label in xLabels {
                label.removeFromSuperview()
            }
            xLabels.removeAll()
        }
        if days.count > 0 {
            let width = ZXLineChartConstant.width / CGFloat(days.count)
            for i in 0..<days.count {
                let label = UILabel.init(frame: CGRect(x: width * CGFloat(i), y: ZXLineChartConstant.chartHeight, width: width, height: 40))
                label.font = UIFont.systemFont(ofSize: 13)
                label.textAlignment = .center
                label.textColor = UIColor.lightGray
                label.highlightedTextColor = ZXLineChartConstant.lineColor
                label.text = days[i]
                self.addSubview(label)
                xLabels.append(label)
            }
        }
    }
    
    fileprivate func buildLineLayer() {
        if linePointValues.count > 0 {
            var maskPath = UIBezierPath()
            if maskLayerPointsValue.count > 0 {
                for (index,value) in maskLayerPointsValue.enumerated() {
                    if index == 0 {
                        maskPath.move(to: value.cgPointValue)
                    }else{
                        maskPath.addLine(to: value.cgPointValue)
                    }
                }
                maskPath.close()
            }else {
                maskPath = UIBezierPath(rect: CGRect.zero)
            }
            self.chartFillColorMaskLayer.path = maskPath.cgPath
            
            //LinePath
            let linePath = UIBezierPath()
            for (index,value) in linePointValues.enumerated() {
                if index == 0 {
                    linePath.move(to: value.cgPointValue)
                }else{
                    linePath.addLine(to: value.cgPointValue)
                }
                self.lineLayer.path = linePath.cgPath
            }
        }else {
            let maskPath = UIBezierPath(rect: CGRect.zero)
            self.chartFillColorMaskLayer.strokeColor = UIColor.clear.cgColor
            self.chartFillColorMaskLayer.path = maskPath.cgPath
        }
        //Start Animation
        self.runLine_FillLayerAnimation()
    }
    
    //清空之前点 清除之前动画 取消之前方法调用
    func reloadData() {
        //Cancel animation
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(runDotsAnimation), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(runPopOverViewAnimation), object: nil)
        self.dotsContentLayer.removeAnimation(forKey: ZXLineChartConstant.dotsAnimationKey)
        self.animationLayer.removeAnimation(forKey: ZXLineChartConstant.lineAnimationKey)
        //Remove PopView
        self.popView.removeFromSuperview()
        //Remove Dots
        if let dots = self.dotsContentLayer.sublayers {
            for dot in dots {
                dot.removeFromSuperlayer()
            }
        }
        self.dotsContentLayer.removeFromSuperlayer()
        self.dotsContentLayer.opacity = 0.0
        self.animationLayer.position = CGPoint(x: -ZXLineChartConstant.width, y: 0)
        //highLightedIndex = 0
        maxYValue = 0
        
        //Clear HighLight
        for label in xLabels {
            label.isHighlighted = false
        }
        if let dataSource = dataSource {
            let count = dataSource.numberOfValues(in: self)
            values.removeAll()
            days.removeAll()
            if count > 0 {
                self.preValue = dataSource.preValue(in: self)
                self.lastValue = dataSource.lastValue(in: self)
                for i in 0..<count {
                    values.append(dataSource.zxLineChartView(self, valueAt: i))
                    days.append(dataSource.zxLineChartView(self, titleAt: i))
                }
                //ReBuild
                buildYLabels()
                buildLineLayer()
                let _ = self.dotLayers
                buildXLables()
            }
        }
    }
}

//绘制动画
extension ZXLineChartView {
    func runLine_FillLayerAnimation() {
        isAnimationFinished = false
        self.animationLayer.position = CGPoint(x: -ZXLineChartConstant.width, y: 0)
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue.init(cgPoint: CGPoint(x: -ZXLineChartConstant.width, y: 0))
        animation.toValue   = NSValue.init(cgPoint: CGPoint(x: 0, y: 0))
        animation.duration = 0.75
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.animationLayer.add(animation, forKey: ZXLineChartConstant.lineAnimationKey)
        self.perform(#selector(runDotsAnimation), with: nil, afterDelay: 0.75)
    }
    
    func runDotsAnimation() {
        self.chartContentLayer.addSublayer(self.dotsContentLayer)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber.init(value: 0)
        animation.toValue = NSNumber.init(value: 1)
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.dotsContentLayer.add(animation, forKey: ZXLineChartConstant.dotsAnimationKey)
        self.perform(#selector(runPopOverViewAnimation), with: nil, afterDelay: 0.3)
    }
    
    func runPopOverViewAnimation() {
        isAnimationFinished = true
        self.selectedPoint(at: highLightedIndex)
        delegate?.zxLineChartView(self, animation: true)
    }
    
}

//Shape 构造 坐标点计算
extension ZXLineChartView {
    
    //通过值，获取计算坐标点
    func pointValue(_ num:NSNumber,index:Int) -> CGPoint {
        let max = self.maxY()
        var x = lineMargin
        if index != 0 {
            x += CGFloat(index) * (ZXLineChartConstant.width - 2 * lineMargin) / CGFloat(values.count - 1)
        }
        var y:CGFloat = 0
        if max <= 1 {
            if floatMaxY > 0 {
                let tempF = self.maxYLess1FloatValue(floatMaxY)
                y = ZXLineChartConstant.chartHeight * CGFloat(1 - num.floatValue / tempF)
            }else {
                y = ZXLineChartConstant.chartHeight * CGFloat(1 - num.floatValue / 1.0)
            }
        } else {
            y = ZXLineChartConstant.chartHeight * CGFloat(1 - num.floatValue / Float(max))
        }
        return CGPoint(x: x, y: y)
    }
    //values 之外的起点坐标
    func prePoint() -> NSValue {
        if let preV = preValue {
            let max = self.maxY()
            var y:CGFloat = 0
            if max <= 1 {
                if floatMaxY > 0 {
                    let tempF = self.maxYLess1FloatValue(floatMaxY)
                    y = ZXLineChartConstant.chartHeight * CGFloat(1 - preV.floatValue / tempF)
                }else {
                    y = ZXLineChartConstant.chartHeight * CGFloat(1 - preV.floatValue / 1.0)
                }
            } else {
                y = ZXLineChartConstant.chartHeight * CGFloat(1 - preV.floatValue / Float(max))
            }
            //有确定的值 不做调整
            //y *= spaceRatio
            //if y > ZXLineChartConstant.chartHeight {
            //    y = ZXLineChartConstant.chartHeight
            //}
            
            return NSValue.init(cgPoint: CGPoint(x: 0, y: y))
        }
        return NSValue.init(cgPoint: CGPoint(x: 0, y: ZXLineChartConstant.chartHeight))
    }
    //values 之外的终点坐标
    func lastPoint() -> NSValue {
        if let lastV = lastValue {
            let max = self.maxY()
            var y:CGFloat = 0
            if max <= 1 {
                if floatMaxY > 0 {
                    let tempF = self.maxYLess1FloatValue(floatMaxY)
                    y = ZXLineChartConstant.chartHeight * CGFloat(1 - lastV.floatValue / tempF)
                }else {
                    y = ZXLineChartConstant.chartHeight * CGFloat(1 - lastV.floatValue / 1.0)
                }
            } else {
                y = ZXLineChartConstant.chartHeight * CGFloat(1 - lastV.floatValue / Float(max))
            }
            //有确定的值 不做调整
            //y *= spaceRatio
            //if y > ZXLineChartConstant.chartHeight {
            //    y = ZXLineChartConstant.chartHeight
            //}
            return NSValue.init(cgPoint: CGPoint(x: ZXLineChartConstant.width, y: y))
        }else {
            let count = pointValues.count
            if count > 0 {
                if count == 1 {//只有一个点
                    var pnt = (pointValues.first?.cgPointValue) ?? CGPoint.zero
                    pnt.x = ZXLineChartConstant.width
                    pnt.y -= 2
                    if pnt.y < 0 {//避免超出顶部绘图边界
                        pnt.y = 0
                    }
                    return NSValue.init(cgPoint: pnt)
                }else{
                    var pnt1 = pointValues.last?.cgPointValue ?? CGPoint.zero
                    let pnt2 = pointValues[count - 2].cgPointValue
                    let ratio = fabs(pnt1.y - pnt2.y) / 2.0
                    //Y小 在上
                    if pnt1.y < pnt2.y {//上升趋势变缓
                        pnt1.y -= ratio * spaceRatio
                        if pnt1.y < 0 {//避免超出顶部绘图边界
                            pnt1.y = 0
                        }
                    } else {
                        pnt1.y += ratio * spaceRatio //下降趋势变缓
                        if pnt1.y > ZXLineChartConstant.chartHeight {//避免底部绘图边界
                            pnt1.y = ZXLineChartConstant.chartHeight
                        }
                    }
                    pnt1.x = ZXLineChartConstant.width
                    return NSValue.init(cgPoint: pnt1)
                }
            }
            return NSValue.init(cgPoint: CGPoint(x: ZXLineChartConstant.width, y: 0))
        }
    }
    //Y轴最大值
    func maxY() -> Int {
        if maxYValue <= 0 {
            if values.count > 0 {
                let sortedNum = values.sorted(by: { (num1, num2) -> Bool in
                    return num1.floatValue > num2.floatValue
                })
                var maxF = sortedNum.first?.floatValue
                if let pre = preValue {
                    maxF = max(maxF!, pre.floatValue)
                }
                if let last = lastValue {
                    maxF = max(maxF!,last.floatValue)
                }
                floatMaxY = maxF!
                maxYValue = min4_10TimesNum(ceilf(maxF!))
            }else { //默认20
                maxYValue = 20
            }
        }
        return maxYValue
    }
    //调整 最大值小于1 是，获取最接近values中最大值 的最大小数
    func maxYLess1FloatValue(_ floatValue: Float) -> Float {
        if floatValue <= 0.01 {
            return 0.01
        }
        var num = Int(floatValue * 10000)
        num = Int(ceilf(Float(num) / 100.0))
        
        if num == 10 {
            return 0.1
        }else if (num < 10) {
            for num in 0..<10 {
                if num % 2 == 0 {
                    break
                }
            }
            return Float(num) / 100.0
        }
        return Float(min4_10TimesNum(floatValue * 100)) / 100.0
    }
    //4 10 倍数，最接近values中最大值
    func min4_10TimesNum(_ fx:Float) -> Int {
        let max = fx
        var num = Int(fx)
        if fx <= 1 {
            return 1
        }
        var find = false
        repeat {
            if num % 4 == 0 {
                if max < 10 {
                    find = true
                }else {
                    if num % 10 == 0 {
                        find = true
                    }
                }
            }
            if !find {
                num += 1
            }
        }while !find
        
        return num
    }
    //选中某个点
    func selectedPoint(at index:Int) {
        if values.count > 0 {
            var tempIndex = index
            if tempIndex < 0 {
                tempIndex = 0
            }
            if tempIndex > values.count - 1 {
                tempIndex = values.count - 1
            }
            if !isAnimationFinished {//动画未开始，提前设定选中的点
                highLightedIndex = tempIndex
                return
            }
            if highLightedIndex >= self.xLabels.count{
                highLightedIndex = self.xLabels.count - 1
            }
            let lastPopLabel = self.xLabels[highLightedIndex]
            lastPopLabel.isHighlighted = false
            if days.count > 0 {
                if tempIndex < days.count {
                    self.xLabels[tempIndex].isHighlighted = true
                }else{
                    fatalError("days label out of bounds")
                }
            }
            
            highLightedIndex = tempIndex
            showPopLabel(at: tempIndex)
        }else{
            highLightedIndex = index
        }
    }
    //显示点值动画
    func showPopLabel(at index:Int) {
        if values.count > 0 {
            self.popView.addSubview(self.popLabel)
            self.addSubview(self.popView)
            self.bringSubview(toFront: self.popView)
//            let num = values[index]
            
            let str = "\(values[index])"
            self.popLabel.text = str
            
            var textSize = (str as NSString).boundingRect(with: CGSize(width: 200, height: 20), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue|NSStringDrawingOptions.truncatesLastVisibleLine.rawValue), attributes: [NSFontAttributeName:self.popLabel.font], context: nil).size
            textSize.width += 20
            self.popLabel.frame = CGRect(x: 0, y: 0, width: textSize.width, height: 20)
            self.popView.frame = CGRect(x: 0, y: 0, width: textSize.width, height: 26)
            let point = pointValues[index].cgPointValue
            
            var offsetX:CGFloat = 0 //处理 poplabel 超出屏幕
            if (point.x - textSize.width / 2.0) < 0 { //左边超出边界
                offsetX = fabs(point.x - textSize.width / 2.0)
            } else if (point.x + textSize.width / 2.0) > UIScreen.main.bounds.width { //右边超出边界
                offsetX = -fabs((UIScreen.main.bounds.width - point.x) - textSize.width / 2.0)
            }
            let startCenter = CGPoint(x: point.x + offsetX, y: point.y)
            let endCenter = CGPoint(x: point.x + offsetX, y: point.y - 20)
            
            
            let popviewMask = CAShapeLayer()
            popviewMask.path = popViewMaskPath(self.popView.frame,offsetX: offsetX)
            self.popView.layer.mask = popviewMask
            
            self.popView.alpha = 0
            self.popView.center = startCenter
            UIView.animate(withDuration: 0.25, animations: {
                self.popView.alpha = 1.0
                self.popView.center = endCenter
            })
        }else {
            self.popView.removeFromSuperview()
        }
    }
    //点值边框路径
    func popViewMaskPath(_ rect:CGRect,offsetX:CGFloat) -> CGPath {
        //Draw     ______
        //        (__  __)
        //           \/
        let path = UIBezierPath()
        let beginX = CGFloat(10)
        let rRatio = CGFloat(rect.size.height - 20)
        path.move(to: CGPoint(x: beginX, y: 0))
        var fixX = -(offsetX / 2.0)
        if fixX < 0 {
            fixX -= 5
        } else if fixX > 0 {
            fixX += 5
        }
        //1______
        path.addLine(to: CGPoint(x: rect.size.width - beginX, y: 0.0))
        //2)
        path.addArc(withCenter: CGPoint(x: rect.size.width - beginX, y: 10), radius: 10, startAngle: -CGFloat( Double.pi / 2.0), endAngle: CGFloat(Double.pi / 2), clockwise: true)
        //3__
        path.addLine(to: CGPoint(x: rect.size.width / 2 + rRatio + fixX, y: 20))
        //4/
        path.addArc(withCenter: CGPoint(x: rect.size.width / 2 + rRatio + fixX, y: rect.size.height), radius: rRatio, startAngle: -CGFloat( Double.pi / 2.0), endAngle: CGFloat( Double.pi), clockwise: false)
        //5\
        path.addArc(withCenter: CGPoint(x: rect.size.width / 2 - rRatio + fixX, y: rect.size.height), radius: rRatio, startAngle: 0, endAngle: -CGFloat( Double.pi / 2.0), clockwise: false)
        //6__
        path.addLine(to: CGPoint(x: beginX, y: 20))
        //7(
        path.addArc(withCenter: CGPoint(x: beginX, y: 10), radius: 10, startAngle: CGFloat( Double.pi / 2.0), endAngle: CGFloat( Double.pi / 2.0 * 3), clockwise: true)
        path.close()
        return path.cgPath
    }
}


//MARK: - 判断是否点击在某个点上
extension ZXLineChartView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchKeyPoint(touches, with: event)
    }
    
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        touchKeyPoint(touches, with: event)
    //    }
    
    func touchKeyPoint(_ touches:Set<UITouch>,with event: UIEvent?) {
        if pointValues.count > 0 {
            if let touch = touches.first {
                let touchPoint = touch.location(in: self)
                if pointValues.count > 1 {
                    for i in 0..<(pointValues.count - 1) {
                        let p1 = pointValues[i].cgPointValue
                        let p2 = pointValues[i + 1].cgPointValue
                        let distanceToP1 = fabs(hypot(touchPoint.x - p1.x, touchPoint.y - p1.y))
                        let distanceToP2 = fabs(hypot(touchPoint.x - p2.x, touchPoint.y - p2.y))
                        let distance = min(distanceToP1, distanceToP2)
                        var compareDistance = ((ZXLineChartConstant.width - self.lineMargin * 2) / CGFloat(values.count) ) / 2
                        if compareDistance > 20 {
                            compareDistance = 20
                        }
                        if compareDistance < 5 {
                            compareDistance = 5
                        }
                        if distance <= compareDistance { //点 周围 20pnt内点击有效
                            let index = (distance == distanceToP2) ? i + 1: i
                            selectedPoint(at: index)
                            delegate?.zxLineChartView(self, selectedAt: index)
                            break
                        }
                    }
                }else {
                    let keyPoint = pointValues.first?.cgPointValue
                    let distance = fabs(hypot(touchPoint.x - (keyPoint?.x)!, touchPoint.y - (keyPoint?.y)!))
                    var compareDistance = ((ZXLineChartConstant.width - self.lineMargin * 2) / CGFloat(values.count) ) / 2
                    if compareDistance > 20 {
                        compareDistance = 20
                    }
                    if compareDistance < 5 {
                        compareDistance = 5
                    }
                    if distance <= compareDistance { //点 周围 20pnt内点击有效
                        selectedPoint(at: 0)
                        delegate?.zxLineChartView(self, selectedAt: 0)
                    }
                }
            }
        }
    }
}

extension ZXLineChartView {
    struct ZXLineChartConstant {
        static let height           =   CGFloat(240.0)
        static let chartHeight      =   CGFloat(200.0)
        static let width            =   UIScreen.main.bounds.width
        static let maskColor        =   UIColor(red: 79 / 255.0, green: 142 / 255.0, blue: 229 / 255.0, alpha: 0.2)
        static let lineColor        =   UIColor(red: 59 / 255.0, green: 135 / 255.0, blue: 239 / 255.0, alpha: 1.0)
        static let backgroundColor  =   UIColor(red: 242 / 255.0, green: 247 / 255.0, blue: 253 / 255.0, alpha: 1.0)
        static let lineAnimationKey =   "LineAndFillColor"
        static let dotsAnimationKey =   "DotsSunRise"
    }
}
