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

class ContactsViewController: ViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var GroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    //var pupils = [Student]()
    var studentPos: Int? = 0
    var currentStudent: Student = Student()
    
    var pupils: List<Student> = List()
    var chats: List<GroupChat> = List()
    var filteredPupils: List<Student> = List()
    var filteredChats: List<GroupChat> = List()
    
    var shouldFilterResult =  false;
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked")
        let enteredText = searchBar.text
        let escapedText = "%"+enteredText!.replacingOccurrences(of: " ", with: "%20")+"%"
        print(filteredChats.count)
        print("escaped text is ",escapedText)
        //TODO: Perform query, set relevant filtered list to results
        self.view.endEditing(true)
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (GroupSegmentedControl.selectedSegmentIndex==0){
            return filteredPupils.count
        } else{
            return filteredChats.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ContactCell")
        
        cell.tag = indexPath.row
        cell.textLabel?.text = "\((self.GroupSegmentedControl.selectedSegmentIndex==0 ? "\(filteredPupils[indexPath.row].name) (\(filteredPupils[indexPath.row].ID))" : "\(filteredChats[indexPath.row].name)")) "
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
            newChat.person1 = self.pupils[indexPath.row]
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
        updatedStudents()
        filteredPupils = pupils
        
        updatedClassesForStudent()
        filteredChats = chats
        
    }
    
    
    func updatedStudents(){
        let realm = try! Realm()
        // print(realm.objects(List<Student>))
        //var pupils = [Student]()
        
        /*for y in (realm.objects(StudentList.self).first?.studentList)! {
            pupils.append(y)
        }*/
        pupils = (realm.objects(StudentList.self).first?.studentList)!
        
        
    }
    
    func updatedClassesForStudent(){
        let realm = try! Realm()
        
        chats = (realm.objects(ClassChatList.self).first?.classChatList)!

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
