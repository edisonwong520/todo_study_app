//
//  SignInViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

var current_user_id = 0
class SignInViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var textfieldsCollection: [UITextField]!
    
    @IBOutlet weak var usernameOrEmail: UITextField! // as First Field that contain username or email in View
    @IBOutlet weak var password: UITextField! // as Second Field that contain password in View
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.textfieldsCollection.forEach { (textfld) in
            textfld.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func quitTapped(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SignInTapped(_ sender: UIButton) {
        
        if password.text == nil{
            password.text = ""
        }
        if usernameOrEmail.text == nil{
            usernameOrEmail.text = ""
        }
        var sql = "SELECT id FROM UserDB WHERE password='\(password.text?.md5()  ?? "\(1)")' AND name ='\(usernameOrEmail.text ?? "\(1)")' ;"
        var login_success_flag = false
        NSLog(sql)
        //result storage user id
        var result = DBManager.shareManager().find_user_id(sql: sql)
        
        if result != -1{
            current_user_id = result
            login_success_flag = true
        }else{
            sql = "SELECT id FROM UserDB WHERE password='\(password.text?.md5() ?? "\(1)")' AND email ='\(usernameOrEmail.text  ?? "\(1)")' ;"
            NSLog(sql)
            result = DBManager.shareManager().find_user_id(sql: sql)
            if result != -1{
                current_user_id = result
                login_success_flag = true
            }
        }
        
        //star to judge
        if login_success_flag == true{
            NSLog("log in success")
            
            let sql = "UPDATE LoginDB SET userid=\(result),flag=1 WHERE id=1;"
            current_user_id = 1
            _ = DBManager.shareManager().execute_sql(sql: sql)
            self.view.window?.rootViewController?.viewDidLoad()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "提示", message: "账号或密码错误，请重新输入", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            present(alert, animated: true, completion: {
                //
            })
        }
        let alert = UIAlertView(title: "提醒", message: "登陆成功！" ,delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        dismiss(animated: true)
        
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard when user touches return key on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 110), animated: true)
    }
    
    

}
