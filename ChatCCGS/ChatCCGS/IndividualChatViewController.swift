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
        print(getAllMessages())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print(getAllMessages().count)
        return getAllMessages().count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("CALLED!")
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")
        var messages = getAllMessages()
        cell.textLabel?.text = messages[indexPath.row].content
        
        return cell
        
    }
    */
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getAllMessages().count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = getAllMessages()[indexPath.row]
        
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")
        //cell.chatName = chat.getName()
        //print(chat.person1)
        cell.textLabel?.text = message.content
        
        
        return cell
    }

    
    func getAllMessages() -> [Message] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        
        var messages = [Message]()
        for r in results {
            // print(" " + r.author)
            // print((chat.person1?.ID)!)
            if r.author == " " + (chat.person1?.ID)! {
                messages.append(r)
            }
        }
        
        
        return messages
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
        
        Alamofire.request(request)
            .authenticate(user: "ccgs", password: "1910")
            .responseString { response in
                debugPrint(response)
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
