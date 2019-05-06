//
//  TabBarViewController.swift
//  Demo_Clock
//
//  Created by edison on 2019/5/6.
//  Copyright © 2019年 luxiaoming. All rights reserved.
//

import UIKit
import SwipeableTabBarController
class TabBarViewController: SwipeableTabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.sideBySide
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "American Typewriter", size: 16)!]
        appearance.setTitleTextAttributes(attributes, for: .normal)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = 67
        tabFrame.origin.y = self.view.frame.size.height - tabFrame.size.height
        self.tabBar.frame = tabFrame
        
        
    }

}
