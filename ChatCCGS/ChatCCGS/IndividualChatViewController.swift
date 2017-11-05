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
    
    // Internal variables
    @objc var chat: IndividualChat = IndividualChat()
    var messages = [(Message, Bool)]()
    @objc var refreshTimer: Timer!

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageContentField: UITextField!
    
    //====VIEW SETUP FUNCTIONS====//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performMessageRefresh()
        refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(performMessageRefresh), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func performMessageRefresh(){
        print(RequestHelper.prepareUrlFor(scriptName: "pullMessage"))
        Alamofire.request(RequestHelper.prepareUrlFor(scriptName: "pullMessage"))
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                print(response)
                
                let realm = try! Realm()
                
                let data = response.result.value?.components(separatedBy: "\n")
                var counter = (data?.count)! - 2
                
                for c in data! {
                    
                    if counter == 0 {
                        break
                    }
                    
                    var c_mutable = c
                    c_mutable.remove(at: c.index(before: c.endIndex))
                    c_mutable.remove(at: c.startIndex)
                    var components = c_mutable.components(separatedBy: ",")
                    
                    let m = Message()
                    m.content = components[1]
                    m.dateStamp = components[2]
                    m.author = components[3]
                    m.recipient = components[4]
                    m.group = components[5]
                    m.isUnreadMessage = true
                    
                    try! realm.write {
                        realm.add(m)
                    }
                    
                    counter -= 1
                }
                self.messages = self.getAllMessages()
                self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destTabController: UITabBarController = segue.destination as! UITabBarController
        
        let destController1: ContactsViewController = destTabController.viewControllers![2].childViewControllers[0] as! ContactsViewController
        
        destController1.currentStudent = (chat.person2)!
        
        let destController2: RecentsViewController = destTabController.viewControllers![1].childViewControllers[0] as! RecentsViewController
        destController2.currentStudent = (chat.person2)!
        
        
        //let destController3: SettingsViewController = destTabController.viewControllers![3].childViewControllers[0] as! SettingsViewController
        //destController3.currentStudent = (chat.person2)!
        
        
        print("segued")
    }
    
    override func viewWillDisappear(_ animated: Bool){
        refreshTimer.invalidate()
    }
    
    //====TABLE VIEW FUNCTIONS====//
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = messages[indexPath.row]
        let message = result.0
        let isUnread = result.1
        
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")

        if isUnread {
            cell.imageView!.image = UIImage(named: "chat")
        }
        
        
        cell.textLabel?.text = message.author + " : " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + "\t\t\t" + message.content //+ unread
        
        return cell
    }

    //====HELPER FUNCTIONS====//
    
    func getAllMessages() -> [(Message, Bool)] {
        
        let realm = try! Realm()
        let results = realm.objects(Message.self)
        var recievedMessages = [(Message, Bool)]()
        
        for r in results {
            if ((r.author == " " + (chat.person1?.ID)! || r.author == (chat.person1?.ID)!) || (r.author ==  " " + (chat.person2?.ID)! ||  r.author == (chat.person2?.ID)!)) && ((r.recipient == " " + (chat.person1?.ID)! || r.recipient == (chat.person1?.ID)!) || (r.recipient ==  " " + (chat.person2?.ID)! ||  r.recipient == (chat.person2?.ID)!)) && (r.group == " None" || r.group == "") {
                
                if r.isUnreadMessage {
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
        return recievedMessages.reversed()
    }
    
    //====MESSAGE PUSHING FUNCTIONS====//
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        if !(RequestHelper.doesContainNonUnicode(message: content)) {
            let dateString = RequestHelper.formatCurrentDateTimeForRequest()
            
            let author = chat.person2?.ID
            let recipient = chat.person1?.ID
            let request = "\(RequestHelper.prepareUrlFor(scriptName: "pushMessage"))&content=\(content)&recipient=\(recipient!)&datestamp=\(dateString)"
            
            let message = Message()
            message.author = " " + author!
            message.dateStamp = RequestHelper.reformatCurrentDateTimeForRealmMessage(dateString: dateString)
            message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
            message.recipient = recipient!
            
            print("requesting: \(request)")
            
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
