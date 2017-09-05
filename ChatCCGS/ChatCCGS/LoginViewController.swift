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
    
    var studentLoggingIn: Student? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ### Code for testing
        usernameField.text = "123"
        passwordField.text = "password123"
        
        // Do any additional setup after loading the view.
        self.retrieveAllStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func login(_ sender: Any) {
        print("Login function called!")
        
        let username = usernameField.text!
        let password = passwordField.text!
        let request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/validate.py?username=" + username + "&password=" + password
        
        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
                switch response.result.value! {
                    
                    case "100 Continue\n":
                        RequestHelper.userUsername = username
                        RequestHelper.userPassword = password
                        print("Yay!")
                        
                        self.retrieveClassesForStudent()
                        
                        let myStudent = Student()
                        myStudent.ID = username
                        
                        self.studentLoggingIn = myStudent
                        self.pullAllMessages(studentID: username, password: password)
                        self.performSegue(withIdentifier: "loggingIn", sender: nil)
                    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destTabController: UITabBarController = segue.destination as! UITabBarController
        
        
        let destController1: ContactsViewController = destTabController.viewControllers![1].childViewControllers[0] as! ContactsViewController
        
        destController1.currentStudent = studentLoggingIn!
        
        let destController2: RecentsViewController = destTabController.viewControllers![0].childViewControllers[0] as! RecentsViewController
        destController2.currentStudent = studentLoggingIn!
        
        let destController3: SettingsViewController = destTabController.viewControllers![2].childViewControllers[0] as! SettingsViewController
        destController3.currentStudent = studentLoggingIn!
        
        print("Student Logging In")
        
    }
    
    func retrieveAllStudents() {
        
        let students = List<Student>()
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1019912/ChatCCGSServerStuff/getStudents.py")
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
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
                    realm.delete(realm.objects(Message.self))
                }
        
                let studentList = StudentList()
                studentList.studentList = students
                
                try! realm.write {
                    realm.add(studentList)
                }
                
        }
        
        
    }
    
    func retrieveClassesForStudent() {
        let request = "http://tartarus.ccgs.wa.edu.au/~1019912/ChatCCGSServerStuff/getClassesForStudent.py?username=\(RequestHelper.userUsername)"
        
        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
                let classes = List<GroupChat>()
                
                for i in (response.result.value?.components(separatedBy: "\n"))! {
                    let chat = GroupChat()
                    chat.name = i
                    classes.append(chat)
                }
                
                let chatList = ClassChatList()
                chatList.classChatList = classes
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(chatList)
                }
                
        }
    }
    
    func pullAllMessages(studentID: String, password: String) {
        
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pullMessage.py?username=" + studentID + "&password=" + password)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                
                debugPrint(response.result.value!)
                
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
                    
                    try! realm.write {
                        realm.add(m)
                    }
                    
                    counter -= 1
                }
                
                print(data!)
                
                
                print(realm.objects(Message.self))
        }
        
    }

}
