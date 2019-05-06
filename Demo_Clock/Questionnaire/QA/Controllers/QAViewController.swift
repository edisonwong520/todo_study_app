//
//  QAViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import Foundation
import UIKit

class QAViewController: UIViewController {
    var pageViewController: UIPageViewController!

    var viewControllers: [UIViewController] = []

    var wrong_answer: [String] = []

    var pageIndex = 0 {
        didSet {
            // 设置当前页面的下一题按钮的标题
            if pageIndex == questions.count - 1 {
                nextButton.setTitle("提交", for: .normal)
            } else {
                nextButton.setTitle("下一题", for: .normal)
            }
        }
    }

    var current_score: Float = 0

    // 其实可以合成一个model
    var questions = [QAQuestion]() // 问题的数组

    var realAnswer = [RealAnswer]() // 回答的数组

    var pageLabel: UILabel! // 页码

    var nextButton: UIButton! // 下一题

    var answerCard: UICollectionView! // 答题卡

    struct AnswerCardFrame {
        let count: Int
        let maximumInLine: Int = 9 // 单行最大
        let space: CGFloat = 10
        let width: CGFloat
        var height: CGFloat {
            let ww = (width - CGFloat(maximumInLine) * space) / CGFloat(maximumInLine)
            let numberOflineDisplay: CGFloat = maximumInLine > count ? 1 : 2
            let hh = (ww + space) * numberOflineDisplay + space
            return hh
        }

        var itemSize: CGSize {
            let ww = (width - CGFloat(maximumInLine) * space) / CGFloat(maximumInLine)
            return CGSize(width: ww, height: ww)
        }
    }

    var answerCardFrame: AnswerCardFrame!

    func allocData() {
        var json: Data
        let filePath = Bundle.main.path(forResource: "DataSource", ofType: "json")
        do {
            json = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: Data.ReadingOptions.dataReadingMapped)

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers)

                let arr = jsonObject as? Array<Any>

                arr?.forEach({ quest in
                    if let question = quest as? [String: Any] {
                        let qqq = QAQuestion(question)
                        questions.append(qqq)
                        //                拿到 questions 之后，再创建realAnswers
                        realAnswer.append(RealAnswer(qqq))
                    }
                })
            } catch {
                NSLog("json decode error")
            }
        } catch {
            NSLog("cann't find dataSource.txt")
        }
    }

    deinit {
        // 取消通知监听
        NotificationCenter.default.removeObserver(self)
    }

    // TODO: lifeCircle
    override func viewDidLoad() {
        title = "Exam"
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false

        // 获取数据
        allocData()

        // 根据数据个数，设置答题卡的坐标
        answerCardFrame = AnswerCardFrame(count: questions.count, width: view.frame.width - 2 * Q_A.Padding.left)

        // 背景
        let backgroundView = UIImageView(frame: view.bounds)
        backgroundView.image = #imageLiteral(resourceName: "background")
        view.addSubview(backgroundView)

        // 当前页码
        pageLabel = UILabel(frame: CGRect(x: view.frame.width - 90 - 15, y: 35, width: 90, height: 50))
        pageLabel.textAlignment = .center
        if #available(iOS 10.0, *) {
            pageLabel.textColor = UIColor(displayP3Red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
        } else {
            // Fallback on earlier versions
        }

        pageLabel.text = "1/\(questions.count)"

        view.addSubview(pageLabel)

        // 主体答题位置
        makePageViewController()

        // 答题答题卡
        makeAnswerCard()

        // 下一题 &&退出答题

        // add 返回按钮
        let backButton = UIButton(type: .custom)
        backButton.setTitle("退出答题", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.backgroundColor = Q_A.Color.blue
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.25, height: 35)

        backButton.layer.cornerRadius = 5
        backButton.layer.masksToBounds = true

        nextButton = UIButton(type: .custom)
        nextButton.setTitle("下一题", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.backgroundColor = Q_A.Color.blue
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nextButton.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.25, height: 35)
        nextButton.center = CGPoint(x: view.frame.width * 0.70, y: pageViewController.view.frame.maxY)
        backButton.center = CGPoint(x: view.frame.width * 0.30, y: pageViewController.view.frame.maxY)
        nextButton.layer.cornerRadius = 5
        nextButton.layer.masksToBounds = true
        view.addSubview(nextButton)
        view.addSubview(backButton)
        // 添加通知
        addNotification()
    }
}

// MARK: 创建UI

extension QAViewController {
    /// 答题的主题位置
    func makePageViewController() {
        // 主体答题位置，设置样式为 pageCurl ，
        pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionSpineLocationKey: NSNumber(value: UIPageViewControllerSpineLocation.min.rawValue)])
        pageViewController.view.frame = CGRect(x: Q_A.Padding.left, y: Q_A.Padding.top, width: view.frame.width - 2 * Q_A.Padding.left, height: view.frame.height - Q_A.Padding.top - answerCardFrame.height - 170)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        pageViewController.isDoubleSided = false // 单面
        pageViewController.cancleSideTouch() // 自定义，取消了边缘响应点击事件

        pageViewController.view.backgroundColor = UIColor.clear

        // 使用UIBezierPath给答题区域添加了一个虚线边框
        let beziel = UIBezierPath(roundedRect: pageViewController.view.bounds, cornerRadius: 5)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = beziel.cgPath
        shapeLayer.lineDashPattern = [5, 2]
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = Q_A.Color.blue.cgColor
        shapeLayer.borderWidth = 1
        shapeLayer.zPosition = -1
        pageViewController.view.layer.addSublayer(shapeLayer)

        // 根据数据个数，设置controller的数组，并设置数据源
        for i in 0 ..< questions.count {
            let current = QAQuestionViewController()
            current.view.frame = pageViewController.view.bounds
            current.dataSource = (questions[i], realAnswer[i])

            viewControllers.append(current)
        }

        pageViewController.setViewControllers([viewControllers.first!], direction: .forward, animated: true) { _ in
            NSLog("设置完成")
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)

            self.pageViewController.didMove(toParentViewController: self) // 前面两句已经加了，这句是什么意思？
        }
    }

    /// 答题卡
    func makeAnswerCard() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5

        answerCard = UICollectionView(frame: CGRect(x: Q_A.Padding.left, y: view.frame.height - answerCardFrame.height - 135, width: answerCardFrame.width, height: answerCardFrame.height), collectionViewLayout: flowLayout)
        answerCard.delegate = self
        answerCard.dataSource = self
        answerCard.backgroundColor = UIColor.white
        answerCard.isPagingEnabled = false
        answerCard.register(UINib(nibName: "QAAnswerCardCell", bundle: nil), forCellWithReuseIdentifier: "QAAnswerCardCell")
        answerCard.showsVerticalScrollIndicator = false

        // 设置边框黄色 背景透明 圆角5
//        answerCard.backgroundColor = UIColor.clear
        answerCard.layer.borderColor = Q_A.Color.blue.cgColor
        answerCard.layer.borderWidth = 0.5
        answerCard.layer.cornerRadius = 5

        view.addSubview(answerCard)
    }
}

// MARK: Actions

extension QAViewController {
    func backButtonAction() {
        NSLog("click back button")
        let alert = UIAlertController(title: "确定退出", message: "退出后未提交的内容将不被保存，是否继续", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续答题", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "退出", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
            
            self.dismiss(animated: true, completion: nil)

        }))
        present(alert, animated: true, completion: {
            //
        })
    }

    func show_result_alert() {}

    func nextButtonAction() {
        if pageIndex < questions.count - 1 {
            NSLog("next button clicked")

            showTargetQuestion(with: pageIndex + 1)

        } else if pageIndex == questions.count - 1 {
            // 最后一个题，提交
            NSLog("next button 提交")
            let alert = UIAlertController(title: "是否提交", message: "提交后不可更改，是否提交", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "继续答题", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "交卷", style: .default, handler: { _ in
                //
                self.checkAndUpload()
                self.show_result()

            }))
            present(alert, animated: true, completion: {
                //
            })
        }
    }

    // show the exam result
    func show_result() {
        var wrong_str = ""
        if wrong_answer.count != 0 {
            wrong_str = "其中第" + wrong_answer.joined(separator: "、") + "题错了"
        }
        let alert = UIAlertController(title: "本次成绩", message: "本次考试您获得了\(current_score)分\n" + wrong_str, preferredStyle: .alert)



        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: {})
    }

    /// 显示相应题目
    ///
    /// - Parameter index: 数组中第几个
    func showTargetQuestion(with index: Int) {
        // 挑走
        if pageIndex < index {
            pageIndex = index
            pageViewController.setViewControllers([viewControllers[pageIndex]], direction: .forward, animated: true) { _ in
                // 完成后去更新 上面的数字
                self.pageLabel.text = "\(index + 1)/\(self.questions.count)"
            }
        } else if pageIndex > index {
            pageIndex = index
            pageViewController.setViewControllers([viewControllers[pageIndex]], direction: .reverse, animated: true) { _ in
                // 完成后去更新 上面的数字
                self.pageLabel.text = "\(index + 1)/\(self.questions.count)"
            }
        }
    }

    // judge score
    func judge_score(qajson: String, answerjson: String) -> Float {
        var score = 0
        wrong_answer = []
        NSLog("qajson:\(qajson)")
        NSLog("answer:\(answerjson)")
        if let jsonData = qajson.data(using: .utf8) {
            let qaArr = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String: AnyObject]]
            if let jsonData = answerjson.data(using: .utf8) {
                let answerArr = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String: AnyObject]]

                if answerArr.count == qaArr.count {
                    for index in 0 ..< (qaArr.count) {
                        let qaid = qaArr[index]["id"] as! Int
                        let answerid = answerArr[index]["id"] as! Int
                        let qastr = qaArr[index]["answer"] as! String
                        let answerstr = answerArr[index]["answer"] as! String
                        if qaid == answerid {
                            if judge_multi_answer(str1: qastr, str2: answerstr) {
                                NSLog("judge_multi_answer:\(qastr)")
                                score += 5
                            } else {
                                wrong_answer.append("\(qaid)")
                            }
                        }
                    }
                }
            }
            return Float(score)
        }

        return -1.0
    }

    // judge multi answer
    func judge_multi_answer(str1: String, str2: String) -> Bool {
        // str1 example: 2|3|4
        // str2 example: 3|2|4   judge wheather they are have the same number

        if str1 == str2 {
            return true
        }
        let strarray: Array = str1.components(separatedBy: "|")

        // str1 example:2
        // str2 example:3|2|4  this situation is also wrong
        if str1.count != str2.count {
            return false
        }
        for item in strarray {
            if item != "" {
                if str2.components(separatedBy: item).count <= 1 {
                    return false
                }
            }
        }
        return true
    }

    /// 检查并提交--检查是否必填项都已完成
    func checkAndUpload() {
        //
        var json: Data
        let unDidAnswers = realAnswer.filter { (answer) -> Bool in
            return (answer.answer.isEmpty && answer.required == 1)
        }

        guard unDidAnswers.count == 0 else {
            NSLog("any question required is not answerd")
            let firstUnDid = realAnswer.index(of: unDidAnswers.first!)
            let alert = UIAlertController(title: "存在未答题的必选项:\(firstUnDid! + 1)题\n请继续答题", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "继续答题", style: .default, handler: { _ in
//
//            }))
            present(alert, animated: true, completion: {
                sleep(2)
            })
            return
        }
        // .准备提交
        let results = realAnswer.map { ["id": $0.questionId, "answer": $0.answer] }

        do {
            let data = try JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)

            let jsonStr = String(data: data, encoding: .utf8)

            // get answer
            let filePath = Bundle.main.path(forResource: "AnswerSource", ofType: "json")
            do {
                json = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: Data.ReadingOptions.dataReadingMapped)
                let answerjson = String(data: json, encoding: .utf8)
                NSLog(jsonStr ?? "what")
                current_score = judge_score(qajson: jsonStr!, answerjson: answerjson!)
                let sql = "INSERT INTO ScoreDB (title,score,userid)VALUES('',\(current_score),\(current_user_id));"
                let boolflag = DBManager.shareManager().execute_sql(sql: sql)
                if boolflag {
                    NSLog("insert score into db success")
                } else {
                    NSLog("insert score into db failed")
                }
                // ---

                NSLog("score:\(current_score)")
            } catch {
                NSLog("cann't find dataSource.txt")
            }

            // --

        } catch {
            NSLog("转json出错了")
        }
    }

    /// 添加通知监听
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(answerChanged), name: Q_A.NotifyName.answerChanged, object: nil)
    }

    /// 通知的事件，如果问题被回答。改变答题卡颜色
    ///
    /// - Parameter notify: notify description
    func answerChanged(notify: Notification) {
        //
        let answer = notify.object as? RealAnswer
        NSLog("answer changed")
        let index = realAnswer.index(of: answer!)

        let cell = answerCard.cellForItem(at: IndexPath(item: index!, section: 0)) as? QAAnswerCardCell

        cell?.isAnswered = !((answer?.answer.isEmpty)!)
    }
}

// MARK: UIPageController的代理事件

extension QAViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 获取即将显示的页面的后一页
        let index = viewControllers.index(of: viewController)!
        if index == viewControllers.count - 1 { // 第一条
            return nil
        }
        return viewControllers[index + 1]
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 获取即将显示的页面的前一页
        let index = viewControllers.index(of: viewController)!
        if index == 0 { // 第一条
            return nil
        }

        return viewControllers[index - 1]
    }

    func pageViewControllerSupportedInterfaceOrientations(_: UIPageViewController) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    // 将要到--
    func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // 提前设置页码数据，如果翻页中途取消的话，在下面设置回去
        let finishOne = pendingViewControllers.first
        let index = viewControllers.index(of: finishOne!)
        pageIndex = index!
        pageLabel.text = "\(index! + 1)/\(questions.count)"
    }

    func pageViewControllerPreferredInterfaceOrientationForPresentation(_: UIPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }

    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // 判断是否成功，不成功，重新设置回去
        if !completed {
            //
            let finishOne = previousViewControllers.first
            let index = viewControllers.index(of: finishOne!)
            pageIndex = index!
            pageLabel.text = "\(index! + 1)/\(questions.count)"
        }
    }
}

// MARK: 答题卡的代理事件

extension QAViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return questions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QAAnswerCardCell", for: indexPath) as! QAAnswerCardCell

        cell.titleLabel.text = "\(indexPath.row + 1)"
        cell.isAnswered = !(realAnswer[indexPath.row].answer.isEmpty)

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return answerCardFrame.itemSize
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(answerCardFrame.space, answerCardFrame.space, answerCardFrame.space, answerCardFrame.space)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 显示相应页面
        showTargetQuestion(with: indexPath.row)
    }
}

// MARK: 拓展UIPageViewController，取消了边缘的点击事件

extension UIPageViewController: UIGestureRecognizerDelegate {
    /// 拓展一个方法，取消UIPageViewController的点击边界翻页
    fileprivate func cancleSideTouch() {
        for ges in gestureRecognizers {
            ges.delegate = self
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        guard gestureRecognizer is UITapGestureRecognizer else {
            return true
        }
        return false
    }
}
