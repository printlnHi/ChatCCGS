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
        return getRecentChats().count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatSelected = getRecentChats()[indexPath.row]
        print("segueing")
        self.performSegue(withIdentifier: "selectDM", sender: nil)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = getRecentChats()[indexPath.row]
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        //cell.chatName = chat.getName()
        //print(chat.person1)
        cell.textLabel?.text = chat.person1?.name
        
        
        return cell
    }
    
    
    /*public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeFromRecentsAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in
            
            let realm = try! Realm()
            let results = realm.objects(IndividualChat.self)
            try! realm.write {
                realm.delete(ch)
            }
        }
        
        //getInfoAction.backgroundColor = UIColor.blue
        return[getInfoAction, addToRecentsAction]
    }*/
    
    func getRecentChats() -> [IndividualChat] {
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        //print(results)
        
        var chats = [IndividualChat]()
        for r in results {
            chats.append(r)
        }
        
        //print(chats)
        return chats
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("In recents view controller")
        
        print(retrieveArchivedMessages())
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
        }
    }
    
    func retrieveArchivedMessages() {
        
        //var request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/archiveQuery.py?username="
        //request += (chatSelected.person2?.ID)! + "&password="
        //request += "password123&"
        // Finish based on modified archive file
        let request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/archiveQuery.py?username=123&password=password123&author=124&from=2017-05-01%2000:00:00&to=2018-05-01%2000:00:00"
        Alamofire.request(request).authenticate(user: "ccgs", password: "1910").responseString { response in
            print("*******")
            debugPrint(response.result.value)
            let realm = try! Realm()
            
            var data = response.result.value?.components(separatedBy: "\n")
            var counter = (data?.count)! - 2
            print(data)
            for c in data! {
                if counter == 0 {
                    print("Breaking")
                    break
                }
                
                
                var c_mutable = c
                c_mutable.remove(at: c.index(before: c.endIndex))
                c_mutable.remove(at: c.startIndex)
                var components = c_mutable.components(separatedBy: ",")
                //print(c_mutable)
                print(components)
                var m = Message()
                m.content = components[1]
                m.dateStamp = components[2]
                m.author = components[3]
                m.recipient = components[4]
                
                try! realm.write {
                    realm.add(m)
                }
                
                print(counter)
                counter -= 1
            }
            
            print(data)
            
            
            print(realm.objects(Message.self))
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
