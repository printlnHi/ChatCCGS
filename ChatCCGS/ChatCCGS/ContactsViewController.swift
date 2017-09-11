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
        print("Str Str = \(alamofireRequestString)")

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
        print("parsing succesful chat query with result \(result)")
        self.filteredChats = List()
        let chats = result.components(separatedBy: ", ")
        //Important to split by ", " not ","

        for chat in chats{
            print(chat)
            if (chat != ""){
                let chatName = extractChatFrom(response: chat)

                let alamofireRequestString = "\(RequestHelper.prepareUrlFor(scriptName: "getStudentsForClass"))&class=\(chatName)"
                print("Request string is \(alamofireRequestString)")
                Alamofire.request(alamofireRequestString).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString { response in
                    print("switching \(response.result.value!)")
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
                        print(students)
                        let newChat: GroupChat = GroupChat()
                        newChat.name = chatNameCopy
                        newChat.members = students
                        print("adding new chat \(newChat)")
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
        print("extractChatFrom has been passed \(response)")
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
            return filteredChats.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ContactCell")

        cell.tag = indexPath.row
        cell.textLabel?.text = "\((self.GroupSegmentedControl.selectedSegmentIndex==0 ? "\(filteredPupils[indexPath.row].name) (\(filteredPupils[indexPath.row].ID))" : "\(filteredChats[indexPath.row].name)")) "

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if GroupSegmentedControl.selectedSegmentIndex == 1 {
            self.chatSelected = filteredChats[indexPath.row]
            self.performSegue(withIdentifier: "classChat", sender: nil)
        }
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (GroupSegmentedControl.selectedSegmentIndex == 0) {

            let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in

                self.studentPos = indexPath.row
                self.performSegue(withIdentifier: "getInfo", sender: nil)

            }

            getInfoAction.backgroundColor = UIColor.blue

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
            let getInfoAction = UITableViewRowAction(style: .default, title: "Info") { (action, index) in
                self.classPos = indexPath.row
                self.performSegue(withIdentifier: "getClassChatInfo", sender: nil)
            }
            getInfoAction.backgroundColor = UIColor.blue

            return [getInfoAction]
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier! == "getInfo" {
            let destViewContrller: ContactInfoViewController = segue.destination as! ContactInfoViewController
            destViewContrller.user = String(describing: studentPos!)
        } else if segue.identifier == "classChat" {
            let destViewController: ClassGroupChatViewController = segue.destination as! ClassGroupChatViewController
            destViewController.currentStudent = currentStudent
            destViewController.group = chatSelected
        } else {
            print("OK~")
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
            retrieveArchivedGroupMessages(studentID: currentStudent.ID, password: "password123", groupID: chat.name)
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



    func retrieveArchivedGroupMessages(studentID: String, password: String, groupID: String) {
        print("HI THIS IS TESTING!")
        var request = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/archiveGroupQuery.py?username="
        request += studentID + "&password="
        request += password + "&groupID="
        request += groupID + "&from=2017-01-01%2000:00:00&to=2019-01-01%2000:00:00"
        Alamofire.request(request).authenticate(user: "ccgs", password: "1910").responseString { response in
            debugPrint(response.result.value as Any)

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
                        print(components)


                        let m = Message()
                        m.content = components[1]
                        m.dateStamp = components[2]
                        m.author = components[3]
                        m.recipient = components[4]
                        m.group = components[5]
                        print("^__^^")
                        print(m)

                        try! realm.write {
                            realm.add(m)
                        }
                        print(realm.objects(Message.self))
                        counter -= 1
                }
            }
        }
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
