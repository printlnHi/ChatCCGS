//
//  AppDelegate.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import Realm
import UserNotifications

//====OBJECT DEFINITIONS====/

class Chat : Object {
    @objc dynamic var hasUnreadMessages: Bool = false
}

class IndividualChat : Chat {
    
    @objc dynamic var person1: Student? = Student()
    @objc dynamic var person2: Student? = Student()
    @objc dynamic var person1IsBlocked = false

}

class GroupChat : Chat {
    @objc dynamic var name: String = ""
    var members = List<Student>()
}

class CustomGroupChat : GroupChat {
    @objc dynamic var ID: String = ""
}

class Message : Object {
    
    @objc dynamic var dateStamp = ""
    @objc dynamic var author = ""
    @objc dynamic var recipient = ""
    @objc dynamic var group = ""
    @objc dynamic var content = ""
    @objc dynamic var isUnreadMessage = false
    
}

class Student : Object {
    @objc dynamic var ID: String = ""
    @objc dynamic var name: String = ""
}

class StudentList : Object {
    var studentList = List<Student>()
}

class ClassChatList : Object {
    var classChatList = List<GroupChat>()
}

/* UNUSED DEFIINITIONS
 class TextMessage : Message {
    @objc var message = ""
}

class FileMessage: Message {
    @objc func getDownloadLink() {}
}*/



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        registerForPushNotifications()
        print("setting applicationIconBadgeNumber to 0")
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background
        print("setting applicationIconBadgeNumber to 0")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    @objc func registerForPushNotifications() {
     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
        (granted, error) in
        print("Permission granted: \(granted)")
        
        guard granted else { return }
        self.getNotificationSettings()
        }
    }
    
    @objc func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute:{
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        RequestHelper.userAPNSToken = token
        //TODO: Send token to server
        print("Device Token for APNS: \(token)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        //This will get the text sent in your notification
        let body = notification.request.content.body
        
        //This works for iphone 7 and above using haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        
        print("!!!!!!!!")
    }
    
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : Any]){
        print("recieved a foreground or background push notification")
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notifications: \(error)")
    }

}

