//
//  IndividualChatViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 23/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import Alamofire

class IndividualChatViewController: UIViewController, UITableViewDataSource {
    
    var chat: IndividualChat = IndividualChat()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageContentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Messages")
        print(getAllUnreadMessages())
        // Do any additional setup after loading the view.
        let realm = try! Realm()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("=======")
        print(getAllMessages())
        return getAllMessages().count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = getAllMessages()[indexPath.row]
        print("CALLED")
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")
        //cell.chatName = chat.getName()
        //print(chat.person1)
        cell.textLabel?.text = "At " + message.dateStamp + ", " + message.author + " wrote: " + message.content
        
        
        return cell
    }

    
    func getAllUnreadMessages() -> [Message] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        // print(results)
        print(";;;;;")
        
        var messages = [Message]()
        for r in results {
            // print(" " + r.author)
            // print((chat.person1?.ID)!)
            if r.author == " " + (chat.person1?.ID)! || r.author ==  " " + (chat.person2?.ID)! ||  r.author == (chat.person2?.ID)! {
                messages.append(r)
            }
        }
        
        print(messages)
        return messages.reversed()
    }
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-d%20hh:mm:ss"
        let dateTime = formatter.string(from: date)
        
        let author = chat.person2?.ID
        let recipient = chat.person1?.ID
        let password = "password123"
        print(content)
        print(dateTime)
        
        var request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pushMessage.py?username="
        request += author!
        request += "&password="
        request += password
        request += "&content="
        request += content
        request += "&recipient="
        request += recipient!
        request += "&datestamp="
        request += dateTime
        print(request)
        
        var message = Message()
        message.author = author!
        message.dateStamp = dateTime.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.recipient = recipient!
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(message)
        }
        print("&&&&&&&")
        //try! realm.commitWrite()
        //tableView.reloadData()
        print(realm.objects(Message.self))
        
        Alamofire.request(request)
            .authenticate(user: "ccgs", password: "1910")
            .responseString { response in
                debugPrint(response)
                self.tableView.reloadData()
                // self.loadView()
                //self.viewDidLoad()
        }
        
        
    }
    
    func getArchivedConversation() -> [Message] {
        return [Message]()
    }
    
    func getAllMessages() -> [Message] {
        
        return getArchivedConversation() + getAllUnreadMessages()
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
