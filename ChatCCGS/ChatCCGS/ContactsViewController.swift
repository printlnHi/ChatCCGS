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

class ContactsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var GroupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        return 18
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("used value from unfished function")
        
        let cell = RecentsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ContactCell")
        cell.textLabel?.text = "\((GroupSegmentedControl.selectedSegmentIndex==0 ? "Individual" : "Group")) Number \(indexPath.row)"
        
        return cell
    }
    
    func getEnrolmentsForStudent() {
        
        let tartarusUser = "ccgs"
        let tartarusPassword = "1910"
        
        let realm = try! Realm()
        
        let student = realm.objects(Student.self).first
        print(student)
        print(student!.ID)
        /*
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/validate.py?username=" + username + "&password=" + password)
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                switch response.result.value! {
                case "100 Continue\n": print("Yay!")
                
                self.performSegue(withIdentifier: "loggingIn", sender: nil)
                    
                case "400 Bad Request\n":
                    break
                case "401 Unauthorized\n":
                    let alert = UIAlertController(title:"Authentication Failed", message: "Your username or password was incorrect.", preferredStyle:.alert)
                    let action = UIAlertAction(title:"OK", style:.default, handler:nil)
                    
                    self.passwordField.text! = ""
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case "Unprocessable Entity\n": break
                // tell the user
                case "Internal Server Error\n": break
                // not happy
                default: break
                    
                }
                
                debugPrint(response.result.value!)
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
