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
        for m in getStudentsForClass() {
            members += m + "\n"
        }
        
        print()
        print(getStudentsForClass())
        
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
    
    func getStudentsForClass() -> [String] {
        let request = RequestHelper.prepareUrlFor(scriptName: "getStudentsForClass") + "&class=\(groupChat.name)"
        print(request)
        var students = [String]()
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
            debugPrint(response.result.value!)
            
            let data = response.result.value?.components(separatedBy: "\n")
            var counter = (data?.count)! - 2
            
            for c in data! {
                
                if counter == 0 {
                    break
                }
                
                var c_mutable = c
                c_mutable.remove(at: c.index(before: c.endIndex))
                c_mutable.remove(at: c.startIndex)
                //print(c_mutable)

                students.append(c_mutable)
                counter -= 1
            }
            
            print(students)
            //return students
        }
        return students
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
