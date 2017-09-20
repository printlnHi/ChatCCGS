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

class Chat : Object {
    
    func getMessages() {}
    func sendMessage() {}
    func muteChat() {}
    func deleteMessage() {}
    func hideChat() {}
    func getName() -> String{ return ""}
}

class IndividualChat : Chat {
    dynamic var person1: Student? = Student()
    dynamic var person2: Student? = Student()
    override func getName() -> String{
        return person2!.name
    }
}

class GroupChat : Chat {
    dynamic var name: String = ""
    var members = List<Student>()
    override func getName() -> String{
        return name
    }
}

class CustomGroupChat : GroupChat {
    func leaveChat() {}
    func addMember() {}
}

class Message : Object {
    dynamic var dateStamp = ""
    dynamic var author = ""
    dynamic var recipient = ""
    dynamic var group = ""
    dynamic var content = ""
}

class TextMessage : Message {
    var message = ""
}

/*
class ImageMessage : Message {
    var image: UIImage? = nil
    func getUIImage() {}
}*/

class FileMessage: Message {
    func getDownloadLink() {}
}

class Student : Object {
    dynamic var ID: String = ""
    dynamic var name: String = ""
}

class StudentList : Object {
    var studentList = List<Student>()
}

class ClassChatList : Object {
    var classChatList = List<GroupChat>()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func registerForPushNotifications() {
     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
        (granted, error) in
        print("Permission granted: \(granted)")
        
        guard granted else { return }
        self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        //TODO: Send token to server
        print("Device Token for APNS: \(token)")
    }
    
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : Any]){
        print("recieved a foreground or background push notification")
    }
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notifications: \(error)")
    }
}

