//
//  AppDelegate.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DBManager.shareManager().initDB()
        filter_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
        notes_list = DBManager.shareManager().find_all_notes() as! [NoteItem]
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
        }

        if application.responds(to: #selector(getter: UIApplication.isRegisteredForRemoteNotifications)) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.alert, UIUserNotificationType.badge], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [UIRemoteNotificationType.sound, UIRemoteNotificationType.alert, UIRemoteNotificationType.badge])
        }

        // If a shortcut was launched, display its information and take the appropriate action

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        guard let shortcutItem = launchedShortcutItem else { return }

        // If there is any shortcutItem,that will be handled upon the app becomes active
        _ = handleShortcutItem(item: shortcutItem)
        // We make it nil after perfom/handle method call for that shortcutItem action
        launchedShortcutItem = nil
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NSLog("didReceiveLocalNotification : \(notification)")
        if application.applicationState == .active {
            if let dict = notification.userInfo {
                let title = dict["title"] as! String

                let alert = UIAlertView(title: "提醒", message: "您设定的 '" + title + "' 时间到了", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }

    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?
    enum ShortcutIdentifier: String {
        case First
        case Second
        case Third

        // MARK: Initializers

        init?(fullNameForType: String) {
            guard let last = fullNameForType.components(separatedBy: ".").last else { return nil }

            self.init(rawValue: last)
        }

        // MARK: Properties

        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(rawValue)"
        }
    }

    func handleShortcutItem(item: UIApplicationShortcutItem) -> Bool {
        
        var handled = false
        // Verify that the provided shortcutItem's type is one handled by the application.
        guard ShortcutIdentifier(fullNameForType: item.type) != nil else { return false }
        guard let shortCutType = item.type as String? else { return false }
        let myTabBar = self.window?.rootViewController as? UITabBarController
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        switch shortCutType {
        case ShortcutIdentifier.First.type:
            myTabBar?.selectedIndex = 0
            let nvc = myTabBar?.selectedViewController as? UINavigationController
            let req = mainStoryboard.instantiateViewController(withIdentifier: "DCClockSettingViewController") as! DCClockSettingViewController
            nvc?.pushViewController(req, animated: true)
            handled = true
            
        case ShortcutIdentifier.Second.type:

            myTabBar?.selectedIndex = 1
            let nvc = myTabBar?.selectedViewController as? UINavigationController
            let req = mainStoryboard.instantiateViewController(withIdentifier: "NoteSettingViewController") as! NoteSettingViewController
            nvc?.pushViewController(req, animated: true)
            handled = true
            
        case ShortcutIdentifier.Third.type:
            myTabBar?.selectedIndex = 2
            let nvc = myTabBar?.selectedViewController as? UINavigationController
            let req = mainStoryboard.instantiateViewController(withIdentifier: "QAViewController") as! QAViewController
            nvc?.pushViewController(req, animated: true)
            
            handled = true
            
        default:
            NSLog("Shortcut Item Handle func")
        }
        
        
        return handled
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcutItem(item: shortcutItem))
    }

//
//    func handleDynamicAction() {
//
//        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//
//        if let homeVC = self.window?.rootViewController as? UINavigationController {
//
//            if let orngVC = mainStoryboard.instantiateViewController(withIdentifier: "OrangeVC") as? OrangeVC {
//
//                orngVC.isItPresentingViaShortcutAction = true
//                homeVC.pushViewController(orngVC, animated: true)
//
//            }
//
//        }
//    }
}
