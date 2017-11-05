//
//  CustomGroupChatViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 13/9/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class CustomGroupChatViewController: GroupChatViewController, UITableViewDelegate, UITableViewDataSource{
    
    // Internal variables
    @objc var groupChat = CustomGroupChat()
    @objc var currentStudent = Student()
    @objc var refreshTimer: Timer!
    
    // Outlets
    @IBOutlet weak var messageContentField: UITextField!
    @IBOutlet weak var groupNamelbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //====VIEW SETUP FUNCTIONS====//
    
    override func viewDidLoad() {
        print("In CustomGroupChatViewController")
        super.viewDidLoad()
        groupNamelbl.text = groupChat.name
        performMessageRefresh()
        refreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(performMessageRefresh), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool){
        refreshTimer.invalidate()
    }
    
    @objc func performMessageRefresh() {
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
                        print("writing \(m)")
                        realm.add(m)
                    }
                    
                    counter -= 1
                }
                self.messages = self.getAllMessages()
                self.tableView.reloadData()
        }
    }
    
    //====TABLE VIEW SETUP====//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = messages[indexPath.row]
        let message = result.0
        let isUnread = result.1
        
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "customGroupChatCell")
 
        if isUnread {
            cell.imageView!.image = UIImage(named: "chat")
        }
        cell.textLabel?.text = message.author + " : " + RequestHelper.reformatDateTimeStampForDisplay(message.dateStamp) + "\t\t\t" + message.content
        
        
        return cell
    }
    
    //====MESSAGE PUSHING FUNCTIONS====//
    
    @IBAction func pushMessage() {
        
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let dateString = RequestHelper.formatCurrentDateTimeForRequest()
        let author = currentStudent.ID
        let name = RequestHelper.escapeStringForUrl(queryString: groupChat.ID)
        
        let request = "\(RequestHelper.tartarusBaseUrl)/CustomGroups/pushGroupMessage.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)&content=\(content)&group=\(name)&datestamp=\(dateString)"
        
        print("requesting: \(request)")
        
        let message = Message()
        message.author = " " + author
        message.dateStamp = dateString.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.group = " '" + name.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        
        if !(RequestHelper.doesContainNonUnicode(message: content)) {
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(message)
            }
            
            Alamofire.request(request)
                
                .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
                .responseString { response in
                    
                    self.messageContentField.text! = ""
                    self.performMessageRefresh()
                    self.tableView.reloadData()
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
    
    //====HELPER FUNCTIONS====//
    
    func getAllMessages() -> [(Message, Bool)] {
        let realm = try! Realm()
        let data = realm.objects(Message.self)
        var recievedMessages = [(Message, Bool)]()
        
        for r in data {
            if " '" + groupChat.ID + "'" == r.group {
                if r.isUnreadMessage {
                    recievedMessages.append((r, true))
                } else {
                    recievedMessages.append((r, false))
                }
                try! realm.write {
                    r.isUnreadMessage = false
                }
                
            }
        }
        
        return recievedMessages.reversed()
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
