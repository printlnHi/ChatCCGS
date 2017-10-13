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
    @IBOutlet weak var GroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!


    var studentPos: Int? = 0
    var currentStudent: Student = Student()
    var chatSelected = GroupChat()
    var classPos: Int? = 0
    var customChatSelected = CustomGroupChat()

    var pupils: List<Student> = List()
    var chats: List<GroupChat> = List()
    var filteredPupils: List<Student> = List()
    var filteredChats: List<GroupChat> = List()

    var shouldFilterResult =  false;

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var enteredText = searchBar.text
        if enteredText == nil{
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
            //Chats are currently being searched
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
        if (searchText==""){
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
        self.filteredChats = List()
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
                    let code = strResponse.substring(with: firstIndex..<fourthIndex)
                    let chatNameCopy = chatName
                    switch code{
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
                        self.filteredChats.append(newChat)
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

        let ID: String = response.substring(with: IDStartIndex..<IDEndIndex)



        let NameStartIndex = response.index(IDEndIndex, offsetBy:3)
        var NameEndIndex = response.index(IDEndIndex, offsetBy: 3)

        while (response[NameEndIndex] != "'" as Character){
            NameEndIndex = response.index(NameEndIndex, offsetBy: 1)
        }

        let Name: String = response.substring(with: NameStartIndex..<NameEndIndex)

        return (ID: ID, Name: Name)
    }

    private func extractChatFrom(response: String) -> String{
        var NameStartIndex = response.startIndex
        //TODO: Make this no longer relient on chat names starting with a number
        while (!RequestHelper.isDigit(response[NameStartIndex])){
            NameStartIndex = response.index(NameStartIndex, offsetBy: 1)
        }

        var NameEndIndex = NameStartIndex

        while (response[NameEndIndex] != "'" as Character){
            NameEndIndex = response.index(NameEndIndex, offsetBy: 1)
        }

        return response.substring(with: NameStartIndex..<NameEndIndex)

    }
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
                let chat = filteredChats[indexPath.row]
                cell.textLabel?.text = chat.name
            } else {
                
                let group = getCustomGroups()[indexPath.row - count - 1]
                cell.textLabel?.text = group.name
                
            }
        }
        //cell.textLabel?.text = "\((self.GroupSegmentedControl.selectedSegmentIndex==0 ? "\(filteredPupils[indexPath.row].name) (\(filteredPupils[indexPath.row].ID))" : "\(filteredChats[indexPath.row].name)")) "

        
        /*
            return cell
        } else {
            let group = getCustomGroups()[indexPath.row - count]
            let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
            cell.textLabel?.text = group.name
            return cell
        }*/
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if GroupSegmentedControl.selectedSegmentIndex == 1 {
            if indexPath.row == filteredChats.count {
                return
            } else if indexPath.row > filteredChats.count {
                self.customChatSelected = getCustomGroups()[indexPath.row - filteredChats.count - 1]
                self.performSegue(withIdentifier: "customChat", sender: nil)
            } else {
                self.chatSelected = filteredChats[indexPath.row]
                self.performSegue(withIdentifier: "classChat", sender: nil)
            }
        }
    }

    func isInRecents(studentID: String) -> Bool {
        let realm = try! Realm()
        let data = realm.objects(IndividualChat.self)
        for d in data {
            if d.person1?.ID == studentID {
                return true
            }
        }
        
        return false
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (GroupSegmentedControl.selectedSegmentIndex == 0) {

            let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in

                self.studentPos = indexPath.row
                self.performSegue(withIdentifier: "getInfo", sender: nil)

            }

            getInfoAction.backgroundColor = UIColor.blue
            
            if !(isInRecents(studentID: filteredPupils[indexPath.row].ID)) {
                let addToRecentsAction = UITableViewRowAction(style: .default, title: "Add to Recents") { (action, index) in
                    
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
                return [getInfoAction]
            }
                
            

        } else {
            if indexPath.row < filteredChats.count {
                let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in
                    self.classPos = indexPath.row
                    self.performSegue(withIdentifier: "getClassChatInfo", sender: nil)
                }
                getInfoAction.backgroundColor = UIColor.blue

                return [getInfoAction]
            } else if indexPath.row > filteredChats.count {
                let leaveGroupAction = UITableViewRowAction(style: .default, title: "Leave Group") { (action, index) in
                    
                    let cell = tableView.cellForRow(at: indexPath)
                    
                    let request = "\(RequestHelper.prepareUrlFor(scriptName: "CustomGroups/leaveGroup"))&group=\((cell?.textLabel?.text)!)"
                    
                    print("leaving group: \(request)")
                    
                    Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: "RequestHelper.tartarusPassword").responseString { response in
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
                                self.TableView.reloadData()
                            } else {
                                print("Alamofire request failed")
                            }
                            
                        }
                    }
                }
                leaveGroupAction.backgroundColor = UIColor.red
                return [leaveGroupAction]
            } else {
                return []
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "getInfo" {
            let destViewContrller: ContactInfoViewController = segue.destination as! ContactInfoViewController
            destViewContrller.user = String(describing: studentPos!)
        } else if segue.identifier == "classChat" {
            let destViewController: ClassGroupChatViewController = segue.destination as! ClassGroupChatViewController

            destViewController.group = chatSelected
        } else if segue.identifier == "customChat" {
            let destViewController: CustomGroupChatViewController = segue.destination as! CustomGroupChatViewController
            destViewController.currentStudent = currentStudent
            destViewController.groupChat = customChatSelected
        } else {
            let destViewController: GroupChatInfoViewController = segue.destination as! GroupChatInfoViewController
            destViewController.pos = String(describing: classPos!)
        }
    }

    private func getInfoOnContact(sender: UITableViewCell) {
        print(sender.tag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updatedStudents()
        filteredPupils = pupils

        updatedClassesForStudent()
        filteredChats = chats

        for chat in chats {
            retrieveArchivedGroupMessages(groupID: chat.name)
        }
        
        for customChat in getCustomGroups() {
            retrieveArchiveCustomGroupMessages(groupID: customChat.name)
            let realm = try! Realm()
        }

        
    }


    private func updatedStudents(){
        let realm = try! Realm()
        pupils = (realm.objects(StudentList.self).first?.studentList)!


    }

    private func updatedClassesForStudent(){
        let realm = try! Realm()

        chats = (realm.objects(ClassChatList.self).first?.classChatList)!


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func GroupSegmentChanged(_ sender: Any) {
        TableView.reloadData()
    }



    func retrieveArchivedGroupMessages(groupID: String) {
        let request = "\(RequestHelper.prepareUrlFor(scriptName: "archiveGroupQuery"))&groupID=\(groupID)&from=\(RequestHelper.timeStamp2017to2019)"
        print("retrieving archived messages: \(request)")
        
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


                        try! realm.write {
                            realm.add(m)
                        }
                        counter -= 1
                }
            }
        }
    }
    
    func retrieveArchiveCustomGroupMessages(groupID: String) {

        let request = "\(RequestHelper.prepareUrlFor(scriptName: "archiveGroupQuery"))&groupID=\(groupID)&from=\(RequestHelper.timeStamp2017to2019)"
        print("Request: " + request)
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
                    
                    try! realm.write {
                        realm.add(m)
                    }
                    
                    counter -= 1
                }
            }
        }
    }
    
    
    func getCustomGroups() -> [CustomGroupChat] {
        let realm = try! Realm()
        
        let data = realm.objects(CustomGroupChat.self)
        var groups = [CustomGroupChat]()
        
        
        for group in data {
            groups.append(group)
        }
        
        return groups
        
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
