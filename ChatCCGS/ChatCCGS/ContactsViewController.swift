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
                
                resetFilteredPupils()
                
            } else{
                
                let alamofireRequestString = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/studentQuery.py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)&query=\(escapedQueryText)"
                performNonEmptyPupilQuery(alamofireRequestString: alamofireRequestString)
    
            }
            
        } else {
            //Chats are currently being searched
            
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
                case "Interal Server Error":
                    //TODO: Alert the user
                    print("Something went wrong - response = \(response)")
                case "204 No Conent\n":
                    fallthrough
                case "204 No Content":
                    self.parseSuccesfulStudentQuery(result: "")
                default:
                    self.parseSuccesfulStudentQuery(result: response.result.value!)
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
    
    
    func parseSuccesfulStudentQuery(result : String){
        self.filteredPupils = List()
        result.enumerateLines{line, _ in
            if (line != ""){
                let components : (ID: String, Name: String) = self.seperateStudentResponse(response: line)
                let newStudent: Student = Student()
                newStudent.ID = components.ID
                newStudent.name = components.Name
                self.filteredPupils.append(newStudent)
            }
        }
        self.TableView.reloadData()
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
    
    func seperateStudentResponse(response: String) -> (ID: String, Name: String){
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
        if segue.identifier! == "getInfo" {
            let destViewContrller: ContactInfoViewController = segue.destination as! ContactInfoViewController
            destViewContrller.user = String(describing: studentPos!)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
