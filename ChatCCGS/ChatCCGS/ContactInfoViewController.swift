//
//  ContactInfoViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 20/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ContactInfoViewController: UIViewController {

    var user = ""
    
    @IBOutlet weak var studentNamelbl: UILabel!
    @IBOutlet weak var studentIDlbl: UILabel!
    @IBOutlet weak var studentEmailBtn: UIButton!
    
    override func viewDidLoad() {
        print(user)
        print(user == "")
        super.viewDidLoad()
        
        let student = getAllStudents()[Int(user)!]
        
        studentNamelbl.text = student.name
        studentIDlbl.text = student.ID
        studentEmailBtn.setTitle(student.ID + "@student.ccgs.wa.edu.au", for: .normal)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendEmail(sender: UIButton) {
        if let url = URL(string: "mailto:\(sender.title(for: .normal))") {
            UIApplication.shared.open(url)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllStudents() -> List<Student> {
        let realm = try! Realm()
        // print(realm.objects(List<Student>))
        //var pupils = [Student]()
        
        /*for y in (realm.objects(StudentList.self).first?.studentList)! {
         pupils.append(y)
         }*/
        var pupils = (realm.objects(StudentList.self).first?.studentList)!
        
        return pupils
        
        
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
