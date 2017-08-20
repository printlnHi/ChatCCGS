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
//import Realm

class LoginViewController: ViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let realm = try! Realm()
        self.retrieveAllStudents()
        print(realm.objects(StudentList.self).first)
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
        
        let tartarusUser = "ccgs"
        let tartarusPassword = "1910"
        
        let realm = try! Realm()
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/validate.py?username=" + username + "&password=" + password)
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                switch response.result.value! {
                    case "100 Continue\n":
                        print("Yay!")
                        
                        self.retrieveClassesForStudent(studentID: username)
                        
                        let realm = try! Realm()
                        
                        let myStudent = Student()
                        myStudent.ID = username
                        
                        let s = realm.objects(Student.self).first
                        try! realm.write {
                            realm.delete(s!)
                        }
                        try! realm.write {
                            realm.add(myStudent)
                        }
                        
                        let student = realm.objects(Student.self).first
                        print(student)
                        
                        
                        self.performSegue(withIdentifier: "loggingIn", sender: nil)
                    
                    case "400 Bad Request\n":
                        break
                    case "401 Unauthorized\n":
                        let alert = UIAlertController(title:"Authentication Failed", message: "Your username or password was incorrect.", preferredStyle:.alert)
                        let action = UIAlertAction(title:"OK", style:.default, handler:nil)
                        
                        self.passwordField.text! = ""
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    
                case "Unprocessable Entity\n": break
                        // tell the user
                case "Internal Server Error\n": break
                        // not happy
                default: break
                    
                }
                
                debugPrint(response.result.value!)
        }
    }
    
    func retrieveAllStudents() {
        
        let tartarusUser = "ccgs"
        let tartarusPassword = "1910"
        let students = List<Student>()
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1019912/ChatCCGSServerStuff/getStudents.py")
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                //print(response.result.value)
                let data = response.result.value?.components(separatedBy: "\n")
                //print(data)
                //print(json)
                for s in data! {
                    if s == "" {
                        continue
                    }
                    let newStudent = Student()
                    newStudent.ID = String(s)
                    students.append(newStudent)
                }
                
                let realm = try! Realm()
                
                var studentList = StudentList()
                studentList.studentList = students
                
                try! realm.write {
                    // realm.add(students)
                    realm.add(studentList)
                }
                
        }
        
        
    }
    
    func retrieveClassesForStudent(studentID: String) {
        
        let tartarusUser = "ccgs"
        let tartarusPassword = "1910"
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1019912/ChatCCGSServerStuff/getClassesForStudent.py?username=" + studentID)
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                print("{}{}{}{}{}")
                debugPrint(response.result.value)
                var classes = List<GroupChat>()
                
                for i in (response.result.value?.components(separatedBy: "\n"))! {
                    var chat = GroupChat()
                    chat.name = i
                    classes.append(chat)
                }
                
                print(classes)
                
                var chatList = ClassChatList()
                chatList.classChatList = classes
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(chatList)
                }
                
        }

    }
}
