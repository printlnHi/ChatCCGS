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

class CustomGroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var groupChat = CustomGroupChat()
    var currentStudent = Student()
    
    @IBOutlet weak var messageContentField: UITextField!
    @IBOutlet weak var groupNamelbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        groupNamelbl.text = groupChat.name
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getAllMessages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = getAllMessages()[indexPath.row]
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "customGroupChatCell")
        cell.textLabel?.text = "At " + message.dateStamp + ", " + message.author + " wrote: " + message.content
        return cell
    }
    
    func getAllMessages() -> [Message] {
        let realm = try! Realm()
        let data = realm.objects(Message.self)
        var messages = [Message]()
        
        for message in data {
            if " '" + groupChat.name + "'" == message.group {
                messages.append(message)
            }
        }
        return messages.reversed()
    }
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        let dateString = RequestHelper.formatCurrentDateTimeForRequest()
        
        let author = currentStudent.ID
        let name = RequestHelper.escapeStringForUrl(queryString: groupChat.name)
        
        let request = "\(RequestHelper.tartarusBaseUrl)/CustomGroups/pushGroupMessage.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)&content=\(content)&group=\(name)&datestamp=\(dateString)"
        
        let message = Message()
        message.author = author
        message.dateStamp = dateString.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.group = " '" + name.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(message)
        }
        
        Alamofire.request(request)
            
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                self.tableView.reloadData()
        }
        
        messageContentField.text! = ""
    
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
