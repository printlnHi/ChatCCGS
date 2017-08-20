//
//  NewChatViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit

class NewChatViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createNewGroupChat() {
        
    }
    
    /*func getIndividualContacts() -> [Student] {
    }*/
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        return 0//getIndividualContacts().count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("used value from unfished function")
        
        //let chat = getIndividualContacts()[indexPath.row]
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        //cell.chatName = chat.getName()
        
        
        return cell
    }
    
    public func tableView(_: UITableView, didSelectRowAt: IndexPath){
        //let selectedChat = getRecentsChats()[didSelectRowAt.row];
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
