//
//  MeViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import UIKit
var daka_begin_flag = false
class MeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var dakaLabel: UILabel!
    // 学习打卡的按钮
    @IBOutlet var dailybonus: UIButton!
    @IBOutlet var UnlogLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var realnameLabel: UILabel!
    @IBOutlet var imgView: UIImageView!
    override func viewDidLoad() {
        loginButton.isHidden = true
        logoutButton.isHidden = true
        UnlogLabel.isHidden = true

        super.viewDidLoad()

        // get current login id  if no one login the current id is 0
        let login_flag = DBManager.shareManager().login_ornot()
        NSLog("loginflag:\(login_flag)")
        current_user_id = DBManager.shareManager().find_current_login_id()

        //
        imgView.layer.borderWidth = 0.5
        imgView.layer.borderColor = UIColor.orange.cgColor
        imgView.clipsToBounds = true
        imgView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(tapGesture:)))
        imgView.addGestureRecognizer(tapGesture)

        // already log in
        if login_flag {
            UnlogLabel.isHidden = true

            loginButton.isHidden = true
            logoutButton.isHidden = false
            let current_user = DBManager.shareManager().find_user_byid(id: current_user_id)
            nameLabel.text = "用户名：" + current_user.name
            realnameLabel.text = "邮箱：" + current_user.email
        } else {
            imgView.image = nil
            UnlogLabel.isHidden = false
            loginButton.isHidden = false
            logoutButton.isHidden = true
            nameLabel.text = ""
            realnameLabel.text = ""
        }
        // Do any additional setup after loading the view.
    }

    @objc func tapAction(tapGesture _: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "更改头像", message: nil,
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "相册选取", style: .default) { _ in
            self.getPhoto()
        }
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { _ in
            self.takePic()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        present(alertController, animated: true, completion: nil)
    }

    func getPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("相册不可用")
            return
        }

        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(picker, animated: true, completion: nil)
    }

    func takePic() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("相册不可用")
            return
        }

        let takePic = UIImagePickerController()
        takePic.allowsEditing = true
        takePic.sourceType = .camera
        takePic.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(takePic, animated: true, completion: nil)
    }

    @objc func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        imgView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }

    @IBAction func LogOutTapped(_: UIButton) {
        if current_user_id > 0 {
            current_user_id = 0
            let sql = "UPDATE LoginDB SET userid=0 , flag=0 WHERE id=1"
            _ = DBManager.shareManager().execute_sql(sql: sql)
        }
        viewDidLoad()
    }

    override func viewWillAppear(_: Bool) {
        viewDidLoad()
//        if daka_begin_flag {
//            dakaLabel.titleLabel?.text = "学习打卡（当前打卡已经开始）"
//        } else {
//            dakaLabel.titleLabel?.text = "学习打卡（当前打卡未开始）"
//        }
    }

    @IBAction func dailybonusTapped(_: Any) {
        daka_begin_flag = !daka_begin_flag

        if daka_begin_flag {
            dakaLabel.text = "（当前打卡已经开始）"
        } else {
            dakaLabel.text = "（当前打卡未开始）"
        }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var strdate = dateFormatter.string(from: now)
        let sql = "INSERT INTO CheckinDB(userid,checkindate)VALUES(\(current_user_id),'\(strdate)');"
        if DBManager.shareManager().execute_sql(sql: sql) {
            NSLog("insert checkindb success")
            _ = DBManager.shareManager().get_today_study_time(userid: current_user_id, today: now)
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            strdate = dateFormatter.string(from: now)
//            let sql = "INSERT INTO StudytimeDB(userid,date,studytime)VALUES(\(current_user_id),'\(strdate)',\(today_study_time));"
//            if !DBManager.shareManager().execute_sql(sql: sql){
//                NSLog("insert today_study_time false")
//            }else{
//                NSLog("insert today_study_time success")
//            }

            // get tody studytime sum
        } else {
            NSLog("insert checkindb failed")
        }
    }
}
