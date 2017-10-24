/*=====================FOR NCSS SUMMER SCHOOL=====================
 This is some code I have written this year for a mobile, for
   Advanced Software Development.*/
//
//  HelperFunctions.swift
//  
//
//  Created by Marcus Handley on 23/8/17.
//
//

import Foundation
import UIKit

class RequestHelper{
    static func escapeStringForUrl(queryString s: String) -> String{
        
        return s.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    
    static func escapeStringForSQL(queryString s: String) -> String{
        print("Used value from unfinished function!")
        let esc = s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "%", with: "\\%").replacingOccurrences(of: "_", with: "\\_")
        return esc
    }
    
    static func formatCurrentDateTimeForRequest() -> String{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatString
        return formatter.string(from: currentDate)
    }
    
    static func reformatCurrentDateTimeForRealmMessage(dateString: String) -> String{
        return dateString.replacingOccurrences(of: "%20", with: " ", options: .literal, range: nil)
        
    }
    static func prepareUrlFor(scriptName: String) -> String{
        return "\(RequestHelper.tartarusBaseUrl)/\(scriptName).py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)"
    }
    
    static func prepareCustomUrlFor(scriptName: String) -> String{
        return "\(RequestHelper.tartarusBaseUrl)/CustomGroups/\(scriptName).py?username=\(RequestHelper.userUsername)&password=\(RequestHelper.userPassword)"
    }
    
    static func isDigit(_ c : Character) -> Bool{
        return "0"<=c && c<="9"
    }
    
    static func doesContainNonUnicode(message: String) -> Bool{
        for c in message{
            if (c>Character(UnicodeScalar(127))){
                return true;
            }
        }
        return false;
    }
    static let tartarusBaseUrl = "http://tartarus.ccgs.wa.edu.au/~1022309/cgibin/ChatCCGS"
    static let tartarusUsername = "ccgs"
    static let tartarusPassword = "1910"
    static var userUsername = "USERNAME NOT SET"
    static var userPassword = "PASSWORD NOT SET"
    static var userAPNSToken = "-2"
    static let timeStamp2017to2019 = "2017-01-01%2000:00:00&to=2019-01-01%2000:00:00"
    private static let dateFormatString = "yyyy-MM-d%20hh:mm:ss"
}

class UIColours{
    //static let BlueColour = UIColours(
}
