//
//  HomeViewController.swift
//  ChatCCGS
//
//  Created by Nick Patrikeos on 31/10/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: ViewController {

    @IBOutlet weak var willRecievePushNotifications: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: Any) {
        self.performSegue(withIdentifier: "logOut", sender: nil)
    }
    
    @IBAction func PushNotificationSwtichChanged(_ sender: Any) {
        
        let enabled: Bool = willRecievePushNotifications.isOn
        var enabledAsInt = 0
        
        if (enabled){
            enabledAsInt = 1
        }
        
        let request = RequestHelper.prepareUrlFor(scriptName: "setToken")+"&token=-1&enabled=\(enabledAsInt)"
        print(request)
        
        Alamofire.request(request).authenticate(user: RequestHelper.tartarusUsername, password: RequestHelper.tartarusPassword).responseString{
            response in
            print(response)
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
