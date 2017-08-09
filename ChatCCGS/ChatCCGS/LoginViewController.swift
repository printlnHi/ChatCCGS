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
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS/validate.py?username=" + username + "&password=" + password)
            .authenticate(user: tartarusUser, password: tartarusPassword)
            .responseString { response in
                switch response.result.value! {
                    case "100 Continue\n": print("Yay!")
                        // Yay!
                    /*
                    var newView: RecentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "recentsScene") as! RecentsViewController
                    print(newView)
                      self.navigationController?.pushViewController(newView, animated: true)*/
                    
                    self.performSegue(withIdentifier: "loggingIn", sender: nil)
                    
                    case "400 Bad Request\n": break
                        // Oh no
                    case "401 Unauthorized\n": break
                        // tell the user
                case "Unprocessable Entity\n": break
                        // tell the user
                case "Internal Server Error\n": break
                        // not happy
                default: break
                    
                }
                
                debugPrint(response.result.value!)
        }
    }
}
