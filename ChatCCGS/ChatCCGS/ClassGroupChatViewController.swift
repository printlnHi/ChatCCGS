//
//  ClassGroupChatViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 6/9/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ClassGroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @objc var group = GroupChat()
    @objc var currentStudent = Student()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageContentField: UITextField!
    var messages = [(Message, Bool)]()
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = messages[indexPath.row]
        let message = result.0
        let isUnread = result.1
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        //cell.textLabel?.text = "At " + message.dateStamp + ", " + message.author + " wrote: " + message.content
        //var unread = ""
        if isUnread {
            cell.imageView!.image = UIImage(named: "chat")
        }
        
        cell.textLabel?.text = message.author + " : " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + "\t\t\t" + message.content //+ unread
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(getAllGroupMessages())
        messages = getAllGroupMessages()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getMembers(for classGroupChat: GroupChat) {
        let request = "tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/getStudentsForClass.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)"
        
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password:RequestHelper.tartarusPassword).responseString { response in
            
        }
        
    }

    func getAllGroupMessages() -> [(Message, Bool)] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        print("**")
        print(results)
        
        var receievedMessages = [(Message, Bool)]()
        
        for r in results {
            var g = r.group
            g = g.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
            if g == group.name {
                print("so that worked")
                if r.isUnreadMessage {
                    receievedMessages.append((r, true))
                } else {
                    receievedMessages.append((r, false))
                }
                try! realm.write {
                    r.isUnreadMessage = false
                }
                
            }
        }
        
        //print(messages)
        // Sort by datetime stamp
        
        return receievedMessages.reversed()
    }
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let dateString = RequestHelper.formatCurrentDateTimeForRequest()
        
        let classCode = group.name
        
        let request = "\(RequestHelper.prepareUrlFor(scriptName: "pushGroupMessage"))&content=\(content)&group=\(classCode)&datestamp=\(dateString)"

        
        let message = Message()
        message.author = RequestHelper.userUsername
        message.dateStamp = dateString.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.group = classCode

        if !(RequestHelper.doesContainNonUnicode(message: content)) {
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(message)
            }
            
            print()
            print(request)
            
            
            Alamofire.request(request)
                .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
                .responseString { response in
                    debugPrint(response.result.value!)
                    self.messages = self.getAllGroupMessages()
                    self.tableView.reloadData()
                    self.messageContentField.text! = ""
            }
            
        } else {
            sendUnicodeAlert()
            messageContentField.text! = ""
        }
    }
    
    func sendUnicodeAlert() {
        let alert = UIAlertController(title: "Message Failed to Send", message: "There was unicode in your message. You cannot send messages containing unicode.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
