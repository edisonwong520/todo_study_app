//
//  SignUpViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class FindPasswordViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var quitButton: UIButton!
    
    
    @IBOutlet weak var userName: UITextField! //as Second Field that contain username in View
    
    @IBOutlet weak var oldpassword: UITextField! //as Fourth Field that contain password in View
    @IBOutlet weak var newpassword: UITextField! //as Fifth Field that contain password-confirm in View
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    @IBAction func confirmTapped(_ sender: UIButton) {
        let md5_str = newpassword.text?.md5() ?? ""
        let id = check_pwd()
        if id != -1 {
            let sql = "UPDATE UserDB SET password='\(md5_str)' WHERE id=\(id);"
            if DBManager.shareManager().execute_sql(sql: sql){
                NSLog("change pwd success")
                let alert = UIAlertView(title: "提醒", message: "密码更改成功！" ,delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                dismiss(animated: true)
                
            }else{
                NSLog("change pwd failed")
            }
        }else{
            let alert = UIAlertView(title: "提醒", message: "信息错误，无法更改" ,delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
    }
    
    
    //find pwd in db
    func check_pwd()->Int{
        
        let md5_str = oldpassword.text?.md5() ?? ""
        var sql = "SELECT id FROM UserDB Where username='\(userName.text ?? "")' AND password='\(md5_str)';"
        var result = DBManager.shareManager().get_single_col(sql: sql)
        if result == ""{
            sql = "SELECT id FROM UserDB Where email='\(userName.text ?? "")' AND password='\(md5_str)';"
            result = DBManager.shareManager().get_single_col(sql: sql)
            if result != ""{
                return Int(result)!
            }
        }else{
            return Int(result)!
        }
        
        
        return -1
    }
    
    @IBAction func quitTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Hide keyboard when user touches return key on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    

}
