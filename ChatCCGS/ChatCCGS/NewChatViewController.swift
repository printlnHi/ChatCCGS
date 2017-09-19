//
//  NewChatViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class NewChatViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentStudent: Student = Student()
    var selectedPeople = [Student]()
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("A new chat")
        print(currentStudent)
        selectedPeople.append(currentStudent)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createNewGroupChat() {
        
        if selectedPeople.count <= 1 {
            alertNotValid()
        } else {
            let groupChat = CustomGroupChat()
            groupChat.name = groupName.text!
            
            for i in selectedPeople {
                groupChat.members.append(i)
            }
            
            print(groupChat)
            
            var request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/CustomGroups/createGroup.py?username="
            request += currentStudent.ID + "&password="
            request += "password123" + "&name="
            request += groupChat.name.replacingOccurrences(of: " ", with: "%20") + "&members="
            
            var members = "["
            var count = groupChat.members.count
            for i in groupChat.members {
                if count != 1 {
                    members += i.ID + ","
                } else {
                    members += i.ID
                }
                count -= 1
            }
            members += "]"
            
            request += members
            
            print(members)
            print(request)
            
            Alamofire.request(request).authenticate(user: "ccgs", password: "1910").responseString { response in
                debugPrint(response.result.value!)
            }
        }
    }
    
    func alertNotValid() {
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getRecentChats().count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HELLO!")
        
        let cell = tableView.cellForRow(at: indexPath)

        
        if (cell?.tag)! == 0 {
            selectedPeople.append(getRecentChats()[indexPath.row].person1!)
            print(selectedPeople)
            let chat = getRecentChats()[indexPath.row]
            
            cell?.textLabel?.text = (chat.person1?.name)! + " [SELECTED]"
            cell?.tag = 1
        } else {
            selectedPeople.remove(at: getIndexFromSelected(of: (cell?.textLabel?.text!)!)!)
            print(selectedPeople)
            let chat = getRecentChats()[indexPath.row]
            cell?.textLabel?.text = (chat.person1?.name)!
            cell?.tag = 0
            
        }
    }
    
    func getIndexFromSelected(of student: String) -> Int? {
        var x = 0
        for s in selectedPeople {
            if student + " [SELECTED]" == s.name {
                return x
            }
            x += 1
        }
        return nil
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = getRecentChats()[indexPath.row]
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        cell.textLabel?.text = chat.person1?.name
        
        return cell
    }
    
    
    func getRecentChats() -> [IndividualChat] {
        
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        var chats = [IndividualChat]()
        print("*******!")
        for r in results {

            if (r.person2?.ID)! == currentStudent.ID {
                chats.append(r)
            }
        }
        
        
        return chats
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
