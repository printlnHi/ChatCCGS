//
//  RecentsViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import RealmSwift

class RecentsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentStudent: Student = Student()
    var chatSelected: IndividualChat = IndividualChat()
    
    
    @IBOutlet weak var tableView: UITableView!

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("the row length is:")
        //print(getRecentChats().count + getCustomGroups().count + 1)
        return getRecentChats().count //+ getCustomGroups().count + 1
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatSelected = getRecentChats()[indexPath.row]
        self.performSegue(withIdentifier: "selectDM", sender: nil)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let count = getRecentChats().count
        let chat = getRecentChats()[indexPath.row]
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        cell.textLabel?.text = chat.person1?.name
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeFromRecentsAction = UITableViewRowAction(style: .default, title: "Remove") { (action, index) in
            
            let realm = try! Realm()
            let results = realm.objects(IndividualChat.self)
            var tbd: IndividualChat? = nil
            for r in results {
                let chat = self.getRecentChats()[indexPath.row]
                if (r.person2?.ID)! == self.currentStudent.ID && (r.person1?.name)! == chat.person1?.name {
                    tbd = chat
                    break
                }
            }
            if tbd != nil {
                try! realm.write {
                    realm.delete(tbd!)
                }
            }
        }
        removeFromRecentsAction.backgroundColor = UIColor.red
        return [removeFromRecentsAction]
    }
    
    func getRecentChats() -> [IndividualChat] {
        
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        var chats = [IndividualChat]()
        
        for r in results {
            if (r.person2?.ID)! == currentStudent.ID {
                chats.append(r)
            }
        }
        
        return chats
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("In recents view controller")
        //for chat in getRecentChats() {
        //    retrieveArchivedMessages(username: (chat.person2?.ID)!, password: "password123", author: (chat.person1?.ID)!)
        //}
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDM" {
            let dest: IndividualChatViewController = segue.destination as! IndividualChatViewController
            dest.chat = chatSelected
        } else if segue.identifier == "newChat" {
            let dest: NewChatViewController = segue.destination as! NewChatViewController
            dest.currentStudent = currentStudent
        }
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
