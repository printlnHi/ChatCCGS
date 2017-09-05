//
//  HelperFunctions.swift
//  
//
//  Created by Marcus Handley on 23/8/17.
//
//

import Foundation

class RequestHelper{
    static func escapeStringForUrl(queryString s: String) -> String{
        
        return s.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    static func escapeStringForSQL(queryString s: String) -> String{
        print("Used value from unfinished function!")
        var esc = s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "%", with: "\\%").replacingOccurrences(of: "_", with: "\\_")
        return esc
    }
    
    static let tartarusUsername = "ccgs"
    static let tartarusPassword = "1910"
    static var userUsername = "USERNAME NOT SET"
    static var userPassword = "PASSWORD NOT SET"
}
