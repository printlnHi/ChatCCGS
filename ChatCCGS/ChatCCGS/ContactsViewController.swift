//
//  ContactsViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ContactsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var GroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    
    //var pupils = [Student]()
    var studentPos: Int? = 0
    var currentStudent: Student = Student()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        var rows = 0
        if (self.GroupSegmentedControl.selectedSegmentIndex==0) {
            rows = 199
        } else {
            rows = 4
        }
        
        return rows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("used value from unfished function!")
        
        let pupils = getAllStudents()
        let chats = getClassesForStudent()
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ContactCell")
        
        cell.tag = indexPath.row
        cell.textLabel?.text = "\((self.GroupSegmentedControl.selectedSegmentIndex==0 ? "\(pupils[indexPath.row].name) (\(pupils[indexPath.row].ID))" : "\(chats[indexPath.row].name)")) "
        
        //cell.target(forAction: #selector(ContactsViewController.getInfoOnContact(sender:)), withSender: self)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in
            //let student = getAllStudents()[indexPath.row]
            self.studentPos = indexPath.row
            self.performSegue(withIdentifier: "getInfo", sender: nil)
            
        }
        
        getInfoAction.backgroundColor = UIColor.blue
        
        let addToRecentsAction = UITableViewRowAction(style: .default, title: "Add to Recents") { (action, index) in
            let realm = try! Realm()
            let newChat = IndividualChat()
            print("MAKING A NEW CHAT")
            newChat.person1 = self.getAllStudents()[indexPath.row]
            newChat.person2 = self.currentStudent
            print(newChat)
            try! realm.write {
                realm.add(newChat)
            }
            
            print(realm.objects(IndividualChat.self))
            
        }
        
        addToRecentsAction.backgroundColor = UIColor.green
        
        return[getInfoAction, addToRecentsAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewContrller: ContactInfoViewController = segue.destination as! ContactInfoViewController
        destViewContrller.user = String(describing: studentPos!)
    }
    
    func getInfoOnContact(sender: UITableViewCell) {
        print(sender.tag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // retrieveAllStudents()
        //getAllStudents()
        print("and now...")
        print(currentStudent)
        // Do any additional setup after loading the view.
        
    }
    
    
    func getAllStudents() -> List<Student> {
        let realm = try! Realm()
        // print(realm.objects(List<Student>))
        //var pupils = [Student]()
        
        /*for y in (realm.objects(StudentList.self).first?.studentList)! {
            pupils.append(y)
        }*/
        var pupils = (realm.objects(StudentList.self).first?.studentList)!
        
        return pupils
        
        
    }
    
    func getClassesForStudent() -> List<GroupChat> {
        let realm = try! Realm()
        
        let chats = (realm.objects(ClassChatList.self).first?.classChatList)!
        
        return chats
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GroupSegmentChanged(_ sender: Any) {
        TableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
