//
//  AppDelegate.swift
//  GameMaster
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        })
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let sepiaInfo = CKSubscription.NotificationInfo()
        sepiaInfo.alertBody = "Players have a question"
        sepiaInfo.shouldBadge = false
        sepiaInfo.soundName = "default"
        sepiaInfo.title = "Sepia"
        
        let platinumInfo = CKSubscription.NotificationInfo()
        platinumInfo.alertBody = "Players have a question"
        platinumInfo.shouldBadge = false
        platinumInfo.soundName = "default"
        platinumInfo.title = "Platinum"
        
        let crimsonInfo = CKSubscription.NotificationInfo()
        crimsonInfo.alertBody = "Players have a question"
        crimsonInfo.shouldBadge = false
        crimsonInfo.soundName = "default"
        crimsonInfo.title = "Crimson"
        
        let sepiaPredicate = NSPredicate(format: "room = %@", "sepia")
        let platinumPredicate = NSPredicate(format: "room = %@", "platinum")
        let crimsonPredicate = NSPredicate(format: "room = %@", "crimson")

        let sepiaSub = CKQuerySubscription(recordType: "Question", predicate: sepiaPredicate, options: .firesOnRecordCreation)
        sepiaSub.notificationInfo = sepiaInfo
        let platinumSub = CKQuerySubscription(recordType: "Question", predicate: platinumPredicate, options: .firesOnRecordCreation)
        platinumSub.notificationInfo = platinumInfo
        let crimsonSub = CKQuerySubscription(recordType: "Question", predicate: crimsonPredicate, options: .firesOnRecordCreation)
        crimsonSub.notificationInfo = crimsonInfo
        
        let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase
        publicDB.save(sepiaSub, completionHandler: { subscription, error in
            if error == nil {
                print("success")
            } else {
                print("fail")
            }
        })
        publicDB.save(platinumSub, completionHandler: { subscription, error in
            if error == nil {
                print("success")
            } else {
                print("fail")
            }
        })
        publicDB.save(crimsonSub, completionHandler: { subscription, error in
            if error == nil {
                print("success")
            } else {
                print("fail")
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])

        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if let mainVC = self.window?.rootViewController as? ViewController {
                    if notification.request.content.title == "Sepia" {
                        mainVC.roomSegmentedControl.selectedSegmentIndex = 0
                    } else if notification.request.content.title == "Platinum" {
                        mainVC.roomSegmentedControl.selectedSegmentIndex = 1
                    } else if notification.request.content.title == "Crimson" {
                        mainVC.roomSegmentedControl.selectedSegmentIndex = 2
                    }
                    mainVC.roomSegmentChanged(mainVC.roomSegmentedControl)
                }
                self.reloadData()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        //Pressed the notification
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func reloadData() {
        if let mainVC = self.window?.rootViewController as? ViewController {
            mainVC.fetchAllHints()
            mainVC.fetchAllPrecans()
            mainVC.fetchAllQuestions()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        reloadData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

