//
//  HelperFunctions.swift
//  
//
//  Created by Marcus Handley on 23/8/17.
//
//

import Foundation

class QueryHelper{
    static func escapeStringForQuery(queryString s: String) -> String{
        return s.replacingOccurrences(of: " ", with: "%20")
    }
    
    static let tartarusUsername = "ccgs"
    static let tartarusPassword = "1910"
    static var userUsername = "USERNAME NOT SET"
    static var userPassword = "PASSWORD NOT SET"
}

