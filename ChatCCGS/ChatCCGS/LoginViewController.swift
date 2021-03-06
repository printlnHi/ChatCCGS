//
//  LoginViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 8/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class LoginViewController: ViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @objc var studentLoggingIn: Student? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.isSecureTextEntry = true
        // ### Code for testing
        //usernameField.text = "123"
        //passwordField.text = "password123"

        // Do any additional setup after loading the view.
        self.retrieveAllStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }


    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue to the tab-bar controller
        
        let destTabController: UITabBarController = segue.destination as! UITabBarController

        let destController1: ContactsViewController = destTabController.viewControllers![2].childViewControllers[0] as! ContactsViewController
        destController1.currentStudent = studentLoggingIn!

        let destController2: RecentsViewController = destTabController.viewControllers![1].childViewControllers[0] as! RecentsViewController
        destController2.currentStudent = studentLoggingIn!

        print("Student Logging In")

    }

    //====DB INTERACTION FUNCTIONS====//
    
    @IBAction func login(_ sender: Any) {
        // Log in to the app
        print("Login function called!")
        
        let username = usernameField.text!
        let password = passwordField.text!
        RequestHelper.userUsername = username
        RequestHelper.userPassword = password
        let request = RequestHelper.prepareUrlFor(scriptName: "validate")
        
        print("requesting: \(request)")
        
        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
                switch response.result.value! {
                    
                case "100 Continue\n":
                    LoginViewController.retrieveCustomGroups(studentID: username)
                    
                    RequestHelper.userUsername = username
                    RequestHelper.userPassword = password
                    
                    self.retrieveClassesForStudent()
                    
                    let myStudent = Student()
                    myStudent.ID = username
                    
                    
                    self.studentLoggingIn = myStudent
                    
                    self.pullAllMessages()
                    self.pullAllArchivedMessages(username: username, password: password)
                    
                    self.performSegue(withIdentifier: "loggingIn", sender: nil)
                    self.setAPNSToken()
                    self.resetNotificationBadge()
                    
                case "400 Bad Request\n":
                    break
                    
                case "401 Unauthorized\n":
                    let alert = UIAlertController(title:"Authentication Failed", message: "Your username or password was incorrect.", preferredStyle:.alert)
                    let action = UIAlertAction(title:"OK", style:.default, handler:nil)
                    
                    self.passwordField.text! = ""
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case "Unprocessable Entity\n":
                    break
                // tell the user
                case "Internal Server Error\n":
                    break
                // not happy
                default: break
                    
                }
        }
    }
    
    @objc func setAPNSToken() {
        // Set the push-notification token for the app
        
        let request = RequestHelper.prepareUrlFor(scriptName: "setToken")+"&token=\(RequestHelper.userAPNSToken)&enabled=\(RequestHelper.userPushNotificationPreferences)"
        print("requesting: \(request)")
        
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString{
            response in
            print(response)
        }
    }

    @objc func resetNotificationBadge(){}

    @objc func retrieveAllStudents() {
        // Retrieve all students in the database
        
        let students = List<Student>()
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1019912/ChatCCGSServerStuff/getStudents.py")
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
                print("response:",response)
                let data = response.result.value?.components(separatedBy: "\n")

                for s in data! {

                    if s == "" {
                        continue
                    }

                    let cpts = s.components(separatedBy: ":")

                    let newStudent = Student()
                    newStudent.ID = cpts[0]
                    newStudent.name = cpts[1]
                    students.append(newStudent)
                }

                let realm = try! Realm()

                try! realm.write {
                    realm.delete(realm.objects(StudentList.self))
                    realm.delete(realm.objects(ClassChatList.self))
                    realm.delete(realm.objects(CustomGroupChat.self))
                    realm.delete(realm.objects(Message.self))
                }

                let studentList = StudentList()
                studentList.studentList = students

                try! realm.write {
                    realm.add(studentList)
                }
        }
    }

    @objc func retrieveClassesForStudent() {
        // Pulls all the classes/groups a student is enrolled in from the DB
        
        let request = RequestHelper.prepareUrlFor(scriptName: "getClassesForStudent")
        print("requesting: \(request)")

        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in

                let classes = List<GroupChat>()
                let data = (response.result.value?.components(separatedBy: "\n"))!
                var counter = data.count - 1
                for i in data {
                    if counter == 0 {
                        break
                    }
                    let chat = GroupChat()
                    chat.name = i
                    classes.append(chat)
                    counter -= 1
                }


                let chatList = ClassChatList()
                chatList.classChatList = classes

                let realm = try! Realm()

                try! realm.write {
                    realm.add(chatList)
                }
        }
    }

    static func retrieveCustomGroups(studentID: String) {
        // Pulls all the custom groups a student is in from the DB

        let request = RequestHelper.prepareUrlFor(scriptName: "CustomGroups/getGroupsForStudent")
        print("requesting: \(request)")

        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in

            let realm = try! Realm()

            let data = response.result.value?.components(separatedBy: "\n")
            var counter = (data?.count)! - 2
            for c in data! {

                if counter == 0 {
                    break
                }

                var c_mutable = c

                c_mutable.remove(at: c.index(before: c.endIndex))
                c_mutable.remove(at: c.startIndex)
                var components = c_mutable.components(separatedBy: ",")

                let group = CustomGroupChat()
                group.name = components[1].replacingOccurrences(of: "'", with: "")
                group.ID = components[0]

                try! realm.write {
                    realm.add(group)
                }

                counter -= 1

            }
        }

    }



    @objc func pullAllArchivedMessages(username: String, password: String) {
        let realm = try! Realm()
        let chats = realm.objects(IndividualChat.self)

        for chat in chats {
            if (chat.person2?.ID)! == username {
                retrieveArchivedMessages(username: username, password: "password123", author: (chat.person1?.ID)!)
            }
        }

    }

    @objc func retrieveArchivedMessages(username: String, password: String, author: String) {

        let request = "\(RequestHelper.prepareUrlFor(scriptName: "archiveQuery"))&author=\(author)&from=\(RequestHelper.timeStamp2017to2019)"
        print("requesting: \(request)")

        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in

            let realm = try! Realm()

            let data = response.result.value?.components(separatedBy: "\n")
            var counter = (data?.count)! - 2

            for c in data! {

                if counter == 0 {
                    break
                }

                var c_mutable = c
                c_mutable.remove(at: c.index(before: c.endIndex))
                c_mutable.remove(at: c.startIndex)
                var components = c_mutable.components(separatedBy: ",")

                let m = Message()
                m.content = components[1]
                m.dateStamp = components[2]
                m.author = components[3]
                m.recipient = components[4]
                m.group = components[5]

                // REMOVAL OF DUPLICATES
                // if ! messageIsDuplicate(content: m.content, dateStamp: m.dateStamp)  then add to realm

                if !(self.messageIsDuplicate(content: m.content, dateStamp: m.dateStamp)) {
                    try! realm.write {
                        realm.add(m)
                    }

                } else {
                    /// print("DUPLICATE DETECTED")
                }


                counter -= 1
            }

        }
    }

    @objc func messageIsDuplicate(content: String, dateStamp: String) -> Bool {

        let realm = try! Realm()
        let messages = realm.objects(Message.self)

        for m in messages {
            if m.content == content && m.dateStamp == dateStamp {
                return true
            }
        }

        return false
    }

}
