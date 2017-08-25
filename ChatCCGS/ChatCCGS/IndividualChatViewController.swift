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

class IndividualChatViewController: UIViewController {
    
    var chat: IndividualChat = IndividualChat()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "messageCell")
        var messages = getAllMessages()
        
        return cell
        
    }
    
    func getAllMessages() -> [Message] {
        let realm = try! Realm()
        
        let results = realm.objects(Message.self)
        
        var messages = [Message]()
        for r in results {
            if r.author == chat.person1?.ID {
                messages.append(r)
            }
        }
        
        
        return messages
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
