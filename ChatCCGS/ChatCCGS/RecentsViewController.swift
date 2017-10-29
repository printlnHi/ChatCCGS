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
    
    @objc var currentStudent: Student = Student()
    @objc var chatSelected: IndividualChat = IndividualChat()
    var chats = [(IndividualChat, Bool)]()
    
    @IBOutlet weak var tableView: UITableView!

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("the row length is:")
        //print(getRecentChats().count + getCustomGroups().count + 1)
        return chats.count //+ getCustomGroups().count + 1
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatSelected = chats[indexPath.row].0
        self.performSegue(withIdentifier: "selectDM", sender: nil)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let chatRecieved = chats[indexPath.row]
        let chat = chatRecieved.0
        let hasUnread = chatRecieved.1
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        if hasUnread && chat.person1IsBlocked == false {
            cell.textLabel?.text = (chat.person1?.name)! //+ " \(UIImage(named: "message"))" //+ " [NEW MESSAGES]"
            cell.imageView?.image = UIImage(named: "message")
        } else if chat.person1IsBlocked == false {
            cell.textLabel?.text = chat.person1?.name
        } else {
            cell.textLabel?.text = (chat.person1?.name)! //+ " [BLOCKED]"
            cell.imageView?.image = UIImage(named: "cancel")
        }
        
        
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeFromRecentsAction = UITableViewRowAction(style: .default, title: "Remove from Recents") { (action, index) in
            
            let realm = try! Realm()
            let results = realm.objects(IndividualChat.self)
            var tbd: IndividualChat? = nil
            for r in results {
                let chat = self.chats[indexPath.row].0
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
            
            tableView.reloadData()
        }
        
        let blockAction = UITableViewRowAction(style: .default, title: "Block") { (action, index ) in

            let request = RequestHelper.prepareUrlFor(scriptName: "blockUser") + "&user=" + (self.chats[indexPath.row].0.person1?.ID)!
            print(request)
            Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                debugPrint(response.result.value!)
                if response.result.value! == "100 Continue\n" {
                    let realm = try! Realm()
                    let results = realm.objects(IndividualChat.self)

                    for r in results {
                        let chat = self.chats[indexPath.row].0
                        if (r.person2?.ID)! == self.currentStudent.ID && (r.person1?.name)! == chat.person1?.name {
                            try! realm.write {
                                r.person1IsBlocked = true
                            }
                            break
                        }
                    }
                    tableView.reloadData()
                }
            }
        }
        
        let unblockAction = UITableViewRowAction(style: .default, title: "Unblock") { (action, index) in
            let request = RequestHelper.prepareUrlFor(scriptName: "unblockUser") + "&user=" + (self.chats[indexPath.row].0.person1?.ID)!
            print(request)
            
            Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                debugPrint(response.result.value!)
                
                if response.result.value! == "100 Continue\n" {
                    let realm = try! Realm()
                    let results = realm.objects(IndividualChat.self)
                    for r in results {
                        let chat = self.chats[indexPath.row].0
                        if (r.person2?.ID)! == self.currentStudent.ID && (r.person1?.name)! == chat.person1?.name {
                            try! realm.write {
                                r.person1IsBlocked = false
                            }
                            break
                        }
                    }
                    tableView.reloadData()
                }
            }
        }
        
        removeFromRecentsAction.backgroundColor = UIColor.red
        blockAction.backgroundColor = UIColor.black
        unblockAction.backgroundColor = UIColor.brown
        
        if self.chats[indexPath.row].0.person1IsBlocked {
            return [removeFromRecentsAction, unblockAction]
        } else {
            return [removeFromRecentsAction, blockAction]
        }
        
    }
    
    func getRecentChats() -> [(IndividualChat, Bool)] {
        
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        var chats = [(IndividualChat, Bool)]()
        
        for r in results {
            if (r.person2?.ID)! == currentStudent.ID {
                print(realm.objects(Message.self))
                if invididualChatHasUnreadMessages(r) {
                    print("hmm")
                    chats.append((r, true))
                } else {
                    chats.append((r, false))
                }
            }
        }
        
        
        print("&&&&&")
        print(chats)
        
        return chats
    }
    
    @objc func invididualChatHasUnreadMessages(_ chat: IndividualChat) -> Bool {
        let realm = try! Realm()
        let messages = realm.objects(Message.self)
        
        for m in messages {
            if m.isUnreadMessage && (m.author == " " + (chat.person1?.ID)! || m.author == (chat.person1?.ID)!) && m.group == " None" {
                return true
            }
        }
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("In recents view controller")
        //for chat in getRecentChats() {
        //    retrieveArchivedMessages(username: (chat.person2?.ID)!, password: "password123", author: (chat.person1?.ID)!)
        //}
        chats = getRecentChats()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chats = getRecentChats()
        
        print("^^^^")
        print(chats)
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
