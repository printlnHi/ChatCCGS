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
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        var rows = 0
        if (self.GroupSegmentedControl.selectedSegmentIndex==0) {
            rows = 200
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
        cell.textLabel?.text = "\((self.GroupSegmentedControl.selectedSegmentIndex==0 ? "<Name> (\(pupils[indexPath.row].ID))" : "\(chats[indexPath.row].name)")) "
            return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // retrieveAllStudents()
        getAllStudents()
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
