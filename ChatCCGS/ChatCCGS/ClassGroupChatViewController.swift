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

    var currentStudent = Student()
    var group = GroupChat()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageContentField: UITextField!
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getAllGroupMessages().count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = getAllGroupMessages()[indexPath.row]
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        cell.textLabel?.text = "At " + message.dateStamp + ", " + message.author + " wrote: " + message.content
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getAllGroupMessages())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMembers(for classGroupChat: GroupChat) {
        var request = "tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/getStudentsForClass.py?"
        request += "username=" + currentStudent.ID + "&password=123"
        
        Alamofire.request(request).authenticate(user: "ccgs", password:"1910").responseString { response in
            
        }
        
    }

    func getAllGroupMessages() -> [Message] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        
        var messages = [Message]()
        for r in results {
            var g = r.group
            g = g.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
            if g == group.name {
                messages.append(r)
            }
        }
        
        return messages.reversed()
    }
    
    @IBAction func pushMessage() {
        let content = messageContentField.text!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-d%20hh:mm:ss"
        let dateTime = formatter.string(from: date)
        
        let author = currentStudent.ID
        let classCode = group.name
        let password = "password123"
        
        var request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/pushGroupMessage.py?username="
        request += author
        request += "&password="
        request += password
        request += "&content="
        request += content
        request += "&group="
        request += classCode
        request += "&datestamp="
        request += dateTime
        print(request)
        let message = Message()
        message.author = author
        message.dateStamp = dateTime.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.content = "'" + content.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil) + "'"
        message.group = classCode
        print(message)
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(message)
        }
        
        Alamofire.request(request)
            .authenticate(user: "ccgs", password: "1910")
            .responseString { response in
                debugPrint(response.result.value!)
                self.tableView.reloadData()
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
