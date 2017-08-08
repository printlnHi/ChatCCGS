import Alamofire

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
    
    Alamofire.request("http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/cgitest2.py?user=1019913")
        .authenticate(user: user, password: password)
        .responseString { response in
            debugPrint(response.result.value!)
    }
}
