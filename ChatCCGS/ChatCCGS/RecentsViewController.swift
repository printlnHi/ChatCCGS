//
//  RecentsViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import RealmSwift

class RecentsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentStudent: Student = Student()
    
    @IBOutlet weak var tableView: UITableView!

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        return getRecentChats().count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Hi there")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("used value from unfished function!!!!")
        
        let chat = getRecentChats()[indexPath.row]
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        //cell.chatName = chat.getName()
        print(chat.person1)
        cell.textLabel?.text = chat.person1?.name
        
        
        return cell
    }
    
    
    func getRecentChats() -> [IndividualChat] {
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        print(results)
        
        var chats = [IndividualChat]()
        for r in results {
            chats.append(r)
        }
        
        print(chats)
        return chats
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Recents!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Haoory")
        tableView.reloadData()
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
