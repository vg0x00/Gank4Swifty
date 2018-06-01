//
//  AppDelegate.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if error != nil || !granted {
                print("debug: push notification feature disabled")
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        APIManager.shared.postDeivceTokenIfNeeded(token: token, failureHandler: nil, successHandler: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register notication with error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("debug received push notification")

        guard let keyWindow = UIApplication.shared.keyWindow,
            let rootTabbarController = keyWindow.rootViewController as? UITabBarController else { return }
        rootTabbarController.selectedIndex = 0
        guard let viewControllers = rootTabbarController.viewControllers,
            let targetNavigationController = viewControllers[rootTabbarController.selectedIndex] as? UINavigationController else { return }
        targetNavigationController.popToRootViewController(animated: true)
        if let homeVC = targetNavigationController.viewControllers.first as? HomeViewController{
            homeVC.fetchCalendarData()
        }
    }
}

