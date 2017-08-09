//
//  LoginViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 8/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: ViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func login(_ sender: Any) {
        print("Login function called!")
        let username = usernameField.text!
        let password = passwordField.text!
        
        let tartarusUser = "ccgs"
        let tartarusPassword = "1910"
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/validate.py?username=" + username + "&password=" + password)
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                switch String(describing: response) {
                    case "100 Continue":
                        // Yay!
                    var newView: RecentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecentsViewController") as! RecentsViewController
                        self.navigationController?.pushViewController(newView, animated: true)
                    case "400 Bad Request": break
                        // Oh no
                    case "401 Unauthorized": break
                        // tell the user
                case "Unprocessable Entity": break
                        // tell the user
                case "Internal Server Error": break
                        // not happy
                default: break
                    
                }
                
                debugPrint(response.result.value!)
        }
    }
}
