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
    
    @objc var chat: IndividualChat = IndividualChat()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageContentField: UITextField!
    var messages = [(Message, Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Messages")
        
        messages = getAllMessages()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = messages[indexPath.row]
        let message = result.0
        let isUnread = result.1
        
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")
        print("()()()")
        print(message.author + " : " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + "\t\t\t" + message.content)
        print(RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp).count)
        
        var unread = ""
        if isUnread {
            unread = " <UNREAD>"
        }
        
        
        cell.textLabel?.text = message.author + " : " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + "\t\t\t" + message.content + unread
        
        
        //"At " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + ", " + message.author + " wrote: " + message.content
        
        return cell
    }

    
    func getAllMessages() -> [(Message, Bool)] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        print(results)
        print("###")
        print((chat.person2?.ID)!)
        print((chat.person1?.ID)!)
        var recievedMessages = [(Message, Bool)]()
        for r in results {
            print("Author:"+r.author)
            print("Recipient"+r.recipient)
            if ((r.author == " " + (chat.person1?.ID)! || r.author == (chat.person1?.ID)!) || (r.author ==  " " + (chat.person2?.ID)! ||  r.author == (chat.person2?.ID)!)) && ((r.recipient == " " + (chat.person1?.ID)! || r.recipient == (chat.person1?.ID)!) || (r.recipient ==  " " + (chat.person2?.ID)! ||  r.recipient == (chat.person2?.ID)!)) && (r.group == " None" || r.group == "") {
                
                if r.isUnreadMessage {
                    print("!!!!")
                    recievedMessages.append((r, true))
                } else {
                    recievedMessages.append((r, false))
                }
                try! realm.write {
                    r.isUnreadMessage = false
                }
                
                // should be a series of 2-tuples, r and isUnread
            }
        }
        
        // Sort messages by date-time stamp
        print(recievedMessages)
        print("[][][]")
        return recievedMessages.reversed()
    }
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let dateString = RequestHelper.formatCurrentDateTimeForRequest()
        
        let author = chat.person2?.ID
        let recipient = chat.person1?.ID
        
        
        let request = "\(RequestHelper.prepareUrlFor(scriptName: "pushMessage"))&content=\(content)&recipient=\(recipient!)&datestamp=\(dateString)"
        let message = Message()
        message.author = author!
        message.dateStamp = RequestHelper.reformatCurrentDateTimeForRealmMessage(dateString: dateString)
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.recipient = recipient!
        
        
        
        print(request)
        print()
        
        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                debugPrint(response.result.value!)
                
                if response.result.value == "100 Continue\n" {
                    let realm = try! Realm()
                    
                    try! realm.write {
                        realm.add(message)
                    }
                    
                    self.messages = self.getAllMessages()
                    self.tableView.reloadData()
                    
                } else if response.result.value == "609 Sender Blocked Recipient\n" {
                    let alert = UIAlertController(title: "User Blocked", message: "You must unblock this user in order to send messages to them.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if response.result.value == "608 Recipient has Blocked Sender\n" {
                    let alert = UIAlertController(title: "Message Did Not Send", message: "This user has blocked you from sending messages.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Message Failed to Send", message: "An error occurred.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destTabController: UITabBarController = segue.destination as! UITabBarController
        
        let destController1: ContactsViewController = destTabController.viewControllers![1].childViewControllers[0] as! ContactsViewController
        
        destController1.currentStudent = (chat.person2)!
        
        let destController2: RecentsViewController = destTabController.viewControllers![0].childViewControllers[0] as! RecentsViewController
        destController2.currentStudent = (chat.person2)!
        
        
        let destController3: SettingsViewController = destTabController.viewControllers![2].childViewControllers[0] as! SettingsViewController
        destController3.currentStudent = (chat.person2)!
        
        
        print("segued")
    }
    
    
    func sendUnicodeAlert() {
        let alert = UIAlertController(title: "Message Edited to Send", message: "There was unicode in your message. We removed it in order to send the message.", preferredStyle: .alert)
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
