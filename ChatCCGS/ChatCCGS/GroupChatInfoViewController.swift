//
//  GroupChatInfoViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 2/9/17.
//  Copyright © 2017  . All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class GroupChatInfoViewController: UIViewController {
    
    @objc var pos = ""
    @objc var groupChat: GroupChat = GroupChat()

    @IBOutlet weak var classNamelbl: UILabel!
    @IBOutlet weak var classStudentslbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupChat = getClassChatClicked()
        classNamelbl.text = groupChat.name
        
        var members = ""
        //for m in getStudentsForClass() {
        //    members += m + "\n"
        //}
        
        //print()
        //print(getStudentsForClass())
        
        classStudentslbl.text! = members
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getClassChatClicked() -> GroupChat {
        let realm = try! Realm()
        let chats = (realm.objects(ClassChatList.self).first?.classChatList)!
        var classes = [GroupChat]()
        for chat in chats {
            classes.append(chat)
        }
        return classes[Int(pos)!]
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
