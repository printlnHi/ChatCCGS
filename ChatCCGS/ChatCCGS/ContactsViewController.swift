//
//  ContactsViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ContactsViewController: ViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // UI Variables
    @IBOutlet weak var GroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!

    // Internal class variables
    var studentPos: Int? = 0
    @objc var currentStudent: Student = Student()
    @objc var chatSelected = GroupChat()
    var classPos: Int? = 0
    @objc var shouldFilterResult =  false;
    @objc var customChatSelected = CustomGroupChat()

    // Internal class variables: Pupils and GroupChats
    var pupils: List<Student> = List()
    var chats = [(GroupChat, Bool)]()
    
    var filteredPupils: List<Student> = List()
    var filteredChats = [(GroupChat, Bool)]()
    var customChats = [(CustomGroupChat, Bool)]()

    
    //=====SEARCHING FUNCTIONS=====//
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        var enteredText = searchBar.text
        if enteredText == nil {
            enteredText = ""
        }
        
        let escapedEnteredText = RequestHelper.escapeStringForSQL(queryString: enteredText!)
        let queryText = "%\(escapedEnteredText)%"
        let escapedQueryText = RequestHelper.escapeStringForUrl(queryString: queryText)

        if (GroupSegmentedControl.selectedSegmentIndex==0){
            //Pupils are currently being searched
            
            if (enteredText==""){
                resetSelectedList()
            } else{

                let alamofireRequestString = "\(RequestHelper.tartarusBaseUrl)/studentQuery.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)&query=\(escapedQueryText)"
                performNonEmptyPupilQuery(alamofireRequestString: alamofireRequestString)

            }

        } else {
            // Chats are currently being searched
            
            if (enteredText==""){
                resetSelectedList()
            } else{

                let almaofireRequestString = "\(RequestHelper.tartarusBaseUrl)/classQuery.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)&class=\(escapedQueryText)"
                performNonEmptyClassQuery(alamofireRequestString: almaofireRequestString)
            }
        }

        self.view.endEditing(true)

    }

    private func performNonEmptyPupilQuery(alamofireRequestString : String){
        
        print("(performNonEmptyPupilQuery) requesting \(alamofireRequestString)")
        
        Alamofire.request(alamofireRequestString)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in
                switch response.result.value!{
                case "400 Bad Request\n":
                    fallthrough
                case "400 Bad Request":
                    fallthrough
                case "Unprocessable Entity\n":
                    fallthrough
                case "Internal Server Error\n":
                    fallthrough
                case "Unprocessable Entity":
                    fallthrough
                case "Interal Server Error":
                    //TODO: Alert the user
                    print("Something went wrong - response = \(response)")
                case "204 No Content\n":
                    fallthrough
                case "204 No Content":
                    self.parseSuccesfulStudentQuery(result: "")
                default:
                    self.parseSuccesfulStudentQuery(result: response.result.value!)
                }
            }
    }

    private func performNonEmptyClassQuery(alamofireRequestString : String){
        
        print("(performNonEmptyClassQuery) requesting \(alamofireRequestString)")
        
        Alamofire.request(alamofireRequestString)
            .authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword)
            .responseString { response in

                switch response.result.value!{

                case "400 Bad Request\n":
                    fallthrough
                case "400 Bad Request":
                    fallthrough
                case "Unprocessable Entity\n":
                    fallthrough
                case "Unprocessable Entity":
                    fallthrough
                case "Internal Server Error":
                    fallthrough
                case "Internal Server Error\n":
                    //TOOD: Alert the user
                    print("Something went wrong - ƒresponse = \(response)")
                case "204 No Content\n":
                    fallthrough
                case "204 No Content":
                    self.parseSuccesfulChatQuery(result: "")
                default:
                    self.parseSuccesfulChatQuery(result: response.result.value!)
                }

        }
    }


    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        resetSelectedList()
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchText=="") {
            resetSelectedList()
        }
    }


    private func parseSuccesfulStudentQuery(result : String){
        self.filteredPupils = getStudentsFromStudentQuery(result: result)
        self.TableView.reloadData()
    }

    private func getStudentsFromStudentQuery(result: String) -> List<Student>{
        let toReturn: List<Student> = List()

        result.enumerateLines{line, _ in
            if (line != ""){
                let components : (ID: String, Name: String) = self.seperateStudent(response: line)
                let newStudent: Student = Student()
                newStudent.ID = components.ID
                newStudent.name = components.Name
                toReturn.append(newStudent)
            }
        }

        return toReturn
    }

    private func parseSuccesfulChatQuery(result : String){
        self.filteredChats = [(GroupChat, Bool)]()
        let chats = result.components(separatedBy: ", ")
        //Important to split by ", " not ","

        for chat in chats{
            if (chat != ""){
                let chatName = extractChatFrom(response: chat)

                let alamofireRequestString = "\(RequestHelper.prepareUrlFor(scriptName: "getStudentsForClass"))&class=\(chatName)"
                Alamofire.request(alamofireRequestString).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                    
                    let strResponse = response.result.value!
                    let firstIndex = strResponse.startIndex
                    let fourthIndex = strResponse.index(firstIndex, offsetBy: 3)
                    let code = strResponse[..<fourthIndex]
                    let chatNameCopy = chatName
                    
                    switch code {
                    case "400":
                        fallthrough
                    case "422":
                        fallthrough
                    case "401":
                        fallthrough
                    case "500":
                        fallthrough
                    case "204":
                        print("Something went wrong - response = \(response)")
                    default:
                        let students = self.getStudentsFromStudentQuery(result: strResponse)
                        let newChat: GroupChat = GroupChat()
                        newChat.name = chatNameCopy
                        newChat.members = students
                        
                        self.filteredChats.append((newChat, false))
                        self.TableView.reloadData()
                    }
                }

            }
        }

    }

    private func resetSelectedList(){
        if (GroupSegmentedControl.selectedSegmentIndex == 0){
            resetFilteredPupils()
        } else{
            resetFilteredChats()
        }
    }
    
    private func resetFilteredPupils(){
        print("Resetting filtered pupils")
        self.filteredPupils = pupils
        TableView.reloadData()
    }

    private func resetFilteredChats(){
        print("Resetting filtered chats")
        self.filteredChats = chats
        TableView.reloadData()
    }

    private func seperateStudent(response: String) -> (ID: String, Name: String){
        let IDStartIndex = response.index(response.startIndex, offsetBy: 1)
        var IDEndIndex = response.index(response.startIndex, offsetBy: 1)


        while (RequestHelper.isDigit(response[IDEndIndex])){
            IDEndIndex = response.index(IDEndIndex, offsetBy: 1)
        }

        let ID: String = String(response[IDStartIndex..<IDEndIndex])
        let NameStartIndex = response.index(IDEndIndex, offsetBy:3)
        var NameEndIndex = response.index(IDEndIndex, offsetBy: 3)

        while (response[NameEndIndex] != "'" as Character){
            NameEndIndex = response.index(NameEndIndex, offsetBy: 1)
        }

        let Name = String(response[NameStartIndex..<NameEndIndex])

        return (ID: ID, Name: Name)
    }

    private func extractChatFrom(response: String) -> String{
        var NameStartIndex = response.startIndex
        //TODO: Make this no longer relient on chat names starting with a number
        while (!RequestHelper.isDigit(response[NameStartIndex])){
            NameStartIndex = response.index(NameStartIndex, offsetBy: 1)
        }

        var NameEndIndex = NameStartIndex

        while (response[NameEndIndex] != "'" as Character) {
            NameEndIndex = response.index(NameEndIndex, offsetBy: 1)
        }

        return String(response[NameStartIndex..<NameEndIndex])

    }
    
    //======TABLE SETUP FUNCIONS=====//
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if (GroupSegmentedControl.selectedSegmentIndex==0){
            return filteredPupils.count
        } else{
            return filteredChats.count + getCustomGroups().count + 1
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ContactCell")
        let count = filteredChats.count
        cell.tag = indexPath.row
        
        if self.GroupSegmentedControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = filteredPupils[indexPath.row].name + " (" + filteredPupils[indexPath.row].ID + ")"
        } else {
            if indexPath.row == count {
                cell.textLabel?.text = "CUSTOM GROUP CHATS"
            } else if indexPath.row < count {
                let chat = filteredChats[indexPath.row].0
                if filteredChats[indexPath.row].1 {
                    cell.textLabel?.text = chat.name
                    cell.imageView?.image = UIImage(named: "message")
                } else {
                    cell.textLabel?.text = chat.name
                }
            } else {
                let result = customChats[indexPath.row - count - 1]
                let group = result.0
                let isUnread = result.1
                cell.textLabel?.text = group.name
                if isUnread {
                    cell.imageView?.image = UIImage(named: "message")
                }
                cell.textLabel?.text = group.name
                
            }
        }
        
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if GroupSegmentedControl.selectedSegmentIndex == 1 {
            if indexPath.row == filteredChats.count {
                return
            } else if indexPath.row > filteredChats.count {
                self.customChatSelected = customChats[indexPath.row - filteredChats.count - 1].0
                self.performSegue(withIdentifier: "customChat", sender: nil)
            } else {
                self.chatSelected = filteredChats[indexPath.row].0
                self.performSegue(withIdentifier: "classChat", sender: nil)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // All actions for any tableView cell, varying on their contents
        
        if (GroupSegmentedControl.selectedSegmentIndex == 0) {
            // Pupils
            
            let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in
                // Get information
                self.studentPos = indexPath.row
                self.performSegue(withIdentifier: "getInfo", sender: nil)
            }

            getInfoAction.backgroundColor = UIColor.blue
            
            if !(isInRecents(studentID: filteredPupils[indexPath.row].ID)) {
                
                let addToRecentsAction = UITableViewRowAction(style: .default, title: "Add to Recents") { (action, index) in
                    // Add to recents
                    let realm = try! Realm()
                    let newChat = IndividualChat()
                    newChat.person1 = self.pupils[indexPath.row]
                    newChat.person2 = self.currentStudent
                    
                    try! realm.write {
                        realm.add(newChat)
                    }
                    
                }
                
                addToRecentsAction.backgroundColor = UIColor.green
                
                return[getInfoAction, addToRecentsAction]
                
            } else {
                // If the student is already in recents
                return [getInfoAction]
            }

        } else {
            // Groups
            
            if indexPath.row < filteredChats.count {
                // Class Groups (Non-custom) No actions
                return []
                
            } else if indexPath.row > filteredChats.count {
                
                // Custom Groups
                let leaveGroupAction = UITableViewRowAction(style: .default, title: "Leave Group") { (action, index) in
                    // Leave Group
                    
                    let cell = tableView.cellForRow(at: indexPath)
                    print(indexPath.row - self.filteredChats.count - 1)
                    let chat = self.customChats[indexPath.row - self.filteredChats.count - 1].0
                    let request = "\(RequestHelper.prepareUrlFor(scriptName: "CustomGroups/leaveGroup"))&group=\(chat.ID)"
                    
                    print("requesting: \(request)")
                    
                    Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                        
                        if response.result.value! == "100 Continue\n" {
                            let realm = try! Realm()
                            let results = realm.objects(CustomGroupChat.self)
                            var tbd: CustomGroupChat? = nil
                            
                            for r in results {
                                if r.name == (cell?.textLabel?.text)! {
                                    tbd = r
                                    break
                                }
                            }
                            
                            if tbd != nil {
                                try! realm.write {
                                    realm.delete(tbd!)
                                }
                                self.customChats = self.getCustomGroups()
                                self.TableView.reloadData()
                                
                            } else {
                                print("Alamofire request failed")
                            }
                            
                        }
                    }
                }
                
                let addToGroupAction = UITableViewRowAction(style: .default, title: "Add to Group") { (action, index) in
                    // Add a new member to a custom group
                    
                    let chat = self.customChats[indexPath.row - self.filteredChats.count - 1].0
                    let alert = UIAlertController(title: "Add to Group", message: "Please enter the ID of the student you would like to add", preferredStyle: .alert)

                    let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
                        if let field = alert.textFields! [0] as? UITextField {
                            
                            let studentID = field.text!
                            let request = "\(RequestHelper.prepareUrlFor(scriptName: "CustomGroups/addToGroup"))&group=\(chat.ID)&members=[\(studentID)]"
                            
                            print("requesting: \(request)")
                            
                            Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                                
                                var title = ""
                                var message = ""
                                
                                if response.result.value! == "100 Continue\n" {
                                    title = "Success!"
                                    message = "\(studentID) was added to the group."
                                } else if response.result.value! == "605 User Already in Group\n" || response.result.value! == "604 Not Enough Members\n" {
                                    title = "Failed."
                                    message = "The user is already in the group."
                                } else if response.result.value! == "601 Recipient Not Found\n" {
                                    title = "Failed."
                                    message = "That person is not a student."
                                } else {}
                                
                                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in })
                                self.present(alert, animated: true, completion: nil)
                                
                            }

                        } else {}
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                    
                    alert.addTextField {(textField) in
                        textField.placeholder = "Student ID"
                    }
                    
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                addToGroupAction.backgroundColor = UIColor.orange
                leaveGroupAction.backgroundColor = UIColor.red
                
                return [leaveGroupAction, addToGroupAction]
            } else {
                // If the cell's contents is CUSTOM GROUP CHATS
                return []
            }
        }
    }
    
    
    @IBAction func GroupSegmentChanged(_ sender: Any) {
        // Switch from Pupils to Groups
        TableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare for all segues to any exterior viewControllers
        
        if segue.identifier! == "getInfo" {
            // Get the information on a student
            let destViewContrller: ContactInfoViewController = segue.destination as! ContactInfoViewController
            destViewContrller.user = String(describing: studentPos!)
            
        } else if segue.identifier == "classChat" {
            // Go to a class GroupChat
            let destViewController: ClassGroupChatViewController = segue.destination as! ClassGroupChatViewController
            destViewController.group = chatSelected
            
        } else if segue.identifier == "customChat" {
            // Go to a custom GroupChat
            let destViewController: CustomGroupChatViewController = segue.destination as! CustomGroupChatViewController
            destViewController.currentStudent = currentStudent
            destViewController.groupChat = customChatSelected
        }
    }

    private func getInfoOnContact(sender: UITableViewCell) {
        print(sender.tag)
    }


    private func updatedStudents() {
        // Update the pupils array
        
        let realm = try! Realm()
        pupils = (realm.objects(StudentList.self).first?.studentList)!
    }

    private func updatedClassesForStudent() {
        // Update the chats array
        
        let realm = try! Realm()
        
        let results = (realm.objects(ClassChatList.self).first?.classChatList)!
        chats = [(GroupChat, Bool)]()
        
        for r in results {
            if classGroupChatHasUnreadMessages(r) {
                chats.append((r, true))
            } else {
                chats.append((r, false))
            }
        }
        
    }

    @objc func retrieveArchivedGroupMessages(groupID: String) {
        // Query the DB for all archived non-custom group messages and add to realm
        
        let request = "\(RequestHelper.prepareUrlFor(scriptName: "archiveGroupQuery"))&groupID=\(groupID)&from=\(RequestHelper.timeStamp2017to2019)"
        print("requesting: \(request)")
        
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in

            switch response.result.value! {
                case "204 No Content\n":
                    break
                case "400 Bad Request\n":
                    break
                default:
                    let realm = try! Realm()
                    
                    let data = response.result.value?.components(separatedBy: "\n")
                    var counter = (data?.count)! - 2

                    for c in data! {

                        if counter == 0 {
                            break
                        }

                        var c_mutable = c
                        c_mutable.remove(at: c.index(before: c.endIndex))
                        c_mutable.remove(at: c.startIndex)
                        var components = c_mutable.components(separatedBy: ",")
                        

                        let m = Message()
                        m.content = components[1]
                        m.dateStamp = components[2]
                        m.author = components[3]
                        m.recipient = components[4]
                        m.group = components[5]

                        if !(self.messageIsDuplicate(content: m.content, dateStamp: m.dateStamp)) {
                            try! realm.write {
                                realm.add(m)
                            }
                        } else {
                            print("DUPLICATE DETECTED!")
                        }
                        
                        counter -= 1
                }
            }
        }
    }
    
    @objc func retrieveArchiveCustomGroupMessages(groupID: String) {
        // Query the DB for all archived custom group messages and add to realm

        let request = "\(RequestHelper.prepareCustomUrlFor(scriptName: "archiveGroupQuery"))&groupID=\(groupID)&from=\(RequestHelper.timeStamp2017to2019)"
        print("requesting: \(request)")
        
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
            
            switch response.result.value! {
            case "204 No Content\n":
                break
            case "400 Bad Request\n":
                break
            case "500 Internal Server Error\n":
                break
            default:
                let realm = try! Realm()
                
                let data = response.result.value?.components(separatedBy: "\n")
                var counter = (data?.count)! - 2
                
                for c in data! {
                    
                    if counter == 0 {
                        break
                    }
                    
                    var c_mutable = c
                    c_mutable.remove(at: c.index(before: c.endIndex))
                    c_mutable.remove(at: c.startIndex)
                    var components = c_mutable.components(separatedBy: ",")

                    let m = Message()
                    m.content = components[1]
                    m.dateStamp = components[2]
                    m.author = components[3]
                    m.recipient = components[4]
                    m.group = components[5]
                    
                    if !(self.messageIsDuplicate(content: m.content, dateStamp: m.dateStamp)) {
                        try! realm.write {
                            realm.add(m)
                        }
                    } else {
                        //print("DUPLICATE DETECTED!")
                    }
                    
                    counter -= 1
                }
            }
        }
    }
    
    //=====HELPER FUNCTIONS=====//
    
    @objc func classGroupChatHasUnreadMessages(_ chat: GroupChat) -> Bool {
        // Returns true if a class group chat has any unread messages, for icons
        
        let realm = try! Realm()
        let messages = realm.objects(Message.self)
        
        for m in messages {
            let g = m.group.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
            if m.isUnreadMessage && g == chat.name {
                return true
            }
        }
        
        return false
    }
    
    
    @objc func isInRecents(studentID: String) -> Bool {
        let realm = try! Realm()
        if currentStudent.ID == studentID { return true }
        let data = realm.objects(IndividualChat.self)
        
        for d in data {
            if d.person1?.ID == studentID {
                return true
            }
        }
        
        return false
    }

    @objc func messageIsDuplicate(content: String, dateStamp: String) -> Bool {
        // Returns true if a message is a duplicate of one being stored in Realm currently
        
        let realm = try! Realm()
        let messages = realm.objects(Message.self)
        
        for m in messages {
            if m.content == content && m.dateStamp == dateStamp {
                return true
            }
        }
        
        return false
    }
    
    func getCustomGroups() -> [(CustomGroupChat, Bool)] {
        // Get all custom groups from Realm
        
        let realm = try! Realm()
        let data = realm.objects(CustomGroupChat.self)
        var groups = [(CustomGroupChat, Bool)]()

        for r in data {
            if customGroupChatHasUnreadMessages(r) {
                groups.append((r, true))
            } else {
                groups.append((r, false))
            }
        }
        
        return groups
    }
    
    @objc func customGroupChatHasUnreadMessages(_ chat: CustomGroupChat) -> Bool {
        // Returns true if a custom group has unread messages, for icons
        
        let realm = try! Realm()
        let messages = realm.objects(Message.self)
        
        for m in messages {
            let g = m.group.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
            if m.isUnreadMessage && g == chat.ID {
                return true
            }
        }
        return false
    }
    
    //====VIEW SETUP FUNCTIONS====//
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatedClassesForStudent()
        filteredChats = chats
        customChats = getCustomGroups()
        
        TableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Retrieve all class gropus, custom groups and archived messages,
        
        updatedStudents()
        filteredPupils = pupils
        
        updatedClassesForStudent()
        filteredChats = chats
        
        customChats = getCustomGroups()
        
        for c in chats {
            retrieveArchivedGroupMessages(groupID: c.0.name)
        }
        
        for customChat in customChats {
            retrieveArchiveCustomGroupMessages(groupID: customChat.0.ID)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
