//
//  MeViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var realnameLabel: UILabel!
    override func viewDidLoad() {
        loginButton.isHidden = true
        logoutButton.isHidden = true
        super.viewDidLoad()
        //get current login id  if no one login the current id is 0
        current_user_id = DBManager.shareManager().find_current_login_id()
        
        let flag = DBManager.shareManager().login_ornot()
        
        //already log in
        if flag{
            NSLog("login or not is true")
            loginButton.isHidden = true
            logoutButton.isHidden = false
            let current_user = DBManager.shareManager().find_user_byid(id: current_user_id)
            nameLabel.text = "用户名：" + current_user.name
            realnameLabel.text = "邮箱：" + current_user.email
        }else{
            loginButton.isHidden = false
            logoutButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func LogOutTapped(_ sender: UIButton) {

    }

    @IBAction func LogInTapped(_ sender: UIButton) {
        
    }

}
