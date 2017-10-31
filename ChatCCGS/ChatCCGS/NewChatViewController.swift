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
    
    @objc var currentStudent: Student = Student()
    @objc var selectedPeople = [Student]()
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NewChatViewController laoded")
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
            
            
            let request = "\(RequestHelper.prepareCustomUrlFor(scriptName: "createGroup"))&name=\(RequestHelper.escapeStringForUrl(queryString: groupChat.name))&members=\(members)"
            print("requesting: \(request)")
            
            Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                debugPrint(response.result.value!)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(groupChat)
            }
            LoginViewController.retrieveCustomGroups(studentID: RequestHelper.userUsername)

        }
    }
    
    @objc func alertNotValid() {
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return getRecentChats().count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)

        
        if (cell?.tag)! == 0 {
            selectedPeople.append(getRecentChats()[indexPath.row].person1!)
            let chat = getRecentChats()[indexPath.row]
            
            cell?.textLabel?.text = (chat.person1?.name)!
            cell?.imageView?.image = UIImage(named: "approval")
            cell?.tag = 1
        } else {
            selectedPeople.remove(at: getIndexFromSelected(of: (cell?.textLabel?.text!)!)!)
            let chat = getRecentChats()[indexPath.row]
            cell?.textLabel?.text = (chat.person1?.name)!
            cell?.imageView?.image = nil
            cell?.tag = 0
            
        }
    }
    
    func getIndexFromSelected(of student: String) -> Int? {
        print(selectedPeople)
        var x = 0
        for s in selectedPeople {
            if student == s.name {
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
    
    
    @objc func getRecentChats() -> [IndividualChat] {
        
        let realm = try! Realm()
        let results = realm.objects(IndividualChat.self)
        var chats = [IndividualChat]()
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
