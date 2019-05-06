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
    @IBOutlet weak var singlescore: UIButton!
    @IBOutlet var dailybonus: UIButton!
    @IBOutlet var UnlogLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var realnameLabel: UILabel!
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet weak var note_count_label: UILabel!
    
    @IBOutlet weak var top_score_label: UILabel!
    
    @IBOutlet weak var study_time_label: UILabel!
    
    override func viewDidLoad() {
        loginButton.isHidden = true
        logoutButton.isHidden = true
        UnlogLabel.isHidden = true
        let result = DBManager.shareManager().get_single_col(sql: "SELECT picurl FROM UserDB WHERE id=\(current_user_id);")
        
        if result != ""{
            load_user_pic()
        }
        super.viewDidLoad()
        dailybonus.backgroundColor = .clear
        dailybonus.layer.borderWidth = 1
        dailybonus.layer.borderColor = UIColor.lightGray.cgColor
        
        singlescore.backgroundColor = .clear
        singlescore.layer.borderWidth = 1
        singlescore.layer.borderColor = UIColor.lightGray.cgColor
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

    func load_user_pic(){
        let sql = "SELECT picurl FROM UserDB WHERE id=\(current_user_id);"
        let result = DBManager.shareManager().get_single_col(sql: sql)
        if result.count != 0{
            do {
            let photoURL = URL.init(fileURLWithPath: pic_path)
            let imageData = try Data(contentsOf: photoURL)
//            imgView.image = UIImage.init(contentsOfFile: result)
            imgView.image = UIImage(data: imageData)
//            imgView.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
            imgView.image?.fixedOrientation()

            NSLog("load user pic success")
            } catch {print("Error loading image : \(error)")
            }
            
        }
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
        
        if #available(iOS 11.0, *) {
            if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let localPath = documentDirectory?.appending(imgName)
                
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                let data = UIImagePNGRepresentation(image)! as NSData
                data.write(toFile: localPath!, atomically: true)
                //let imageData = NSData(contentsOfFile: localPath!)!
                let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
                pic_path = "" + localPath!
                NSLog("localpath:"+localPath!)
                
                let sql = "UPDATE UserDB SET picurl='\(pic_path)' WHERE id=\(current_user_id);"
                NSLog(sql)
                let boolflag = DBManager.shareManager().execute_sql(sql: sql)
                if !boolflag{
                    NSLog("UPDATE UserDB SET picurl failed")
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
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
    
    func get_all_study_time(){
        var time_count:Float = 0
        let sql = "SELECT studytime FROM StudytimeDB WHERE userid='\(current_user_id)';"
        let result = DBManager.shareManager().get_single_col_array(sql: sql)
        for item in result{
            time_count += Float(item)!
        }
        self.study_time_label.text = "当前学习总时长为：\(time_count)"
    }
    
    
    func get_all_note_count(){
        var note_count = 0
        let sql = "SELECT id FROM NoteDB WHERE userid='\(current_user_id)';"
        let result = DBManager.shareManager().get_single_col_array(sql: sql)
        for item in result{
            note_count += !
        }
        self.study_time_label.text = "当前学习总时长为：\(time_count)"
    }
}
