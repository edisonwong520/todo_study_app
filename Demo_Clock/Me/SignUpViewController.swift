//
//  SignUpViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet var textfieldsCollection: [UITextField]!
    
    @IBOutlet weak var realName: UITextField! // as First Field that contain name in View
    @IBOutlet weak var userName: UITextField! //as Second Field that contain username in View
    @IBOutlet weak var emailAddr: UITextField! //as Third Field that contain email address in View
    @IBOutlet weak var password: UITextField! //as Fourth Field that contain password in View
    @IBOutlet weak var passwordConfirmation: UITextField! //as Fifth Field that contain password-confirm in View
    

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    @IBAction func signupTapped(_ sender: UIButton) {
        if !check_pwd(){
            return
        }
        if !check_email(){
            let alert = UIAlertView(title: "提醒", message: "邮箱格式不对" ,delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let user = UserItem()
        user.name = userName.text!
        user.email = emailAddr.text!
        user.realname = realName.text!
        user.password = (password.text?.md5())!
        DBManager.shareManager().insert_user_db(user: user)
        let alert1 = UIAlertView(title: "提醒", message: "注册成功！" ,delegate: nil, cancelButtonTitle: "OK")
        alert1.show()
        dismiss(animated: true)
        
    }
    
    func check_email()->Bool{
        let email = emailAddr.text
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailTest.evaluate(with: email)
    }
    
    func check_pwd()->Bool{
        if password.text != passwordConfirmation.text{
            let alert = UIAlertView(title: "提醒", message: "两次密码不一样，请重新输入" ,delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return false
        }
        return true
    }
    
    @IBAction func quitTapped(_ sender: Any) {
        dismiss(animated: true)
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
