//
//  RecentsViewController.swift
//  ChatCCGS
//
//  Created by Marcus Handley on 1/8/17.
//  Copyright © 2017 NullPointerAcception. All rights reserved.
//

import UIKit
import Alamofire

class RecentsViewController: ViewController, UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("used value from unfished function")
        return 18
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("used value from unfished function")
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ConversationCell")
        cell.textLabel?.text = "Conversation Number \(indexPath.row)"
        
        return cell
    }
    
    func request() {
        /*
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        Alamofire.request("https://www.google.com.au").responseData { response in
            debugPrint("All Response Info: \(response)")
            
            if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }*/
        let user = "ccgs"
        let password = "1910"
        
        Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/cgitest.py")
            .authenticate(user: user, password: password)
            .responseString { response in
                debugPrint(response.result.value!)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        request()
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

}
