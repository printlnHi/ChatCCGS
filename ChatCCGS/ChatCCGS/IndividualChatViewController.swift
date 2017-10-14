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
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getAllMessages().count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = getAllMessages()[indexPath.row]
        let cell = TableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "individualChatCell")
        cell.textLabel?.text = "At " + message.dateStamp + ", " + message.author + " wrote: " + message.content
        
        return cell
    }

    
    @objc func getAllMessages() -> [Message] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        print(results)
        print("###")
        print((chat.person2?.ID)!)
        print((chat.person1?.ID)!)
        var messages = [Message]()
        for r in results {
            print("Author:"+r.author)
            print("Recipient"+r.recipient)
            if ((r.author == " " + (chat.person1?.ID)! || r.author == (chat.person1?.ID)!) || (r.author ==  " " + (chat.person2?.ID)! ||  r.author == (chat.person2?.ID)!)) && ((r.recipient == " " + (chat.person1?.ID)! || r.recipient == (chat.person1?.ID)!) || (r.recipient ==  " " + (chat.person2?.ID)! ||  r.recipient == (chat.person2?.ID)!)) {
                messages.append(r)
            }
        }
        
        return messages.reversed()
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
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(message)
        }
        
        print(request)
        print()
        
        Alamofire.request(request)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                self.tableView.reloadData()
                debugPrint(response.result.value!)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
