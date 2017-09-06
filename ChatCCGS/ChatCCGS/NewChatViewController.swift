//
//  NewChatViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class NewChatViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentStudent: Student = Student()
    var selectedPeople = [Student]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("A new chat")
        print(currentStudent)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createNewGroupChat() {
        
    }
    
    /*func getIndividualContacts() -> [Student] {
    }*/
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getRecentChats().count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HELLO!")
        let cell = tableView.cellForRow(at: indexPath)
        selectedPeople.append(getRecentChats()[indexPath.row].person1!)
        print(selectedPeople)
        cell?.backgroundColor = UIColor.green
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = getRecentChats()[indexPath.row]
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        cell.textLabel?.text = chat.person1?.name
        
        return cell
    }
    
    
    func getRecentChats() -> [IndividualChat] {
        
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        var chats = [IndividualChat]()
        print("*******!")
        for r in results {
            print(r.person2?.ID)
            print("{}")
            print(currentStudent.ID)
            if (r.person2?.ID)! == currentStudent.ID {
                chats.append(r)
            }
        }
        
        
        return chats
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
