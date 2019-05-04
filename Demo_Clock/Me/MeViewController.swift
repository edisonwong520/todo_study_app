//
//  MeViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/4.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {
    @IBOutlet var UnlogLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var realnameLabel: UILabel!
    override func viewDidLoad() {
        loginButton.isHidden = true
        logoutButton.isHidden = true
        UnlogLabel.isHidden = true

        super.viewDidLoad()
        // get current login id  if no one login the current id is 0
        var login_flag = DBManager.shareManager().login_ornot()
        NSLog("loginflag:\(login_flag)")
        current_user_id = DBManager.shareManager().find_current_login_id()

        // already log in
        if login_flag {
            UnlogLabel.isHidden = true

            loginButton.isHidden = true
            logoutButton.isHidden = false
            let current_user = DBManager.shareManager().find_user_byid(id: current_user_id)
            nameLabel.text = "用户名：" + current_user.name
            realnameLabel.text = "邮箱：" + current_user.email
        } else {
            UnlogLabel.isHidden = false
            loginButton.isHidden = false
            logoutButton.isHidden = true
            nameLabel.text = ""
            realnameLabel.text = ""
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func LogOutTapped(_: UIButton) {
        if current_user_id > 0 {
            current_user_id = 0
            let sql = "UPDATE LoginDB SET userid=0 , flag=0 WHERE id=1"
            _ = DBManager.shareManager().execute_sql(sql: sql)
        }
        viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }
}
