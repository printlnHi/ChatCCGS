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

class ClassGroupChatViewController: UIViewController {

    var currentStudent = Student()
    var group = GroupChat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentStudent)
        print(group)
        print(group.members)
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

    func getAllMessages() {
        let realm = try! Realm()
        print(realm.objects(Message.self))
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
