//
//  SignInViewController.swift
//  LoginPopup
//
//  Created by Chris Chang on 20/02/2018.
//  Copyright © 2018 Chris Chang. All rights reserved.
//

import UIKit


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
        
        /*
         !!!ADD HERE YOUR SIGN IN CODE!!!
         
         WHEN USER TAPPED SIGN IN BUTTON, THIS METHOD
         WILL BE CALLED.
         
         */
        if password.text == nil{
            password.text = ""
        }
        if usernameOrEmail.text == nil{
            usernameOrEmail.text = ""
        }
        var sql = "SELECT id FROM UserDB WHERE password='\(password.text?.md5()  ?? "\(1)")' AND name ='\(usernameOrEmail.text ?? "\(1)")' ;"
        var login_flag = false
        NSLog(sql)
        var result = DBManager.shareManager().find_user_id(sql: sql)
        if result != -1{
            login_flag = true
        }else{
            sql = "SELECT id FROM UserDB WHERE password='\(password.text?.md5() ?? "\(1)")' AND email ='\(usernameOrEmail.text  ?? "\(1)")' ;"
            NSLog(sql)
            result = DBManager.shareManager().find_user_id(sql: sql)
            if result != -1{
                login_flag = true
            }
        }
        
        //star to judge
        if login_flag == true{
            NSLog("log in success")
        }else{
            let alert = UIAlertController(title: "提示", message: "账号或密码错误，请重新输入", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            present(alert, animated: true, completion: {
                //
            })
        }
        
        
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
