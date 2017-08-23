//
//  HelperFunctions.swift
//  
//
//  Created by Marcus Handley on 23/8/17.
//
//

import Foundation

func escapeStringForQuery(queryString s: String) -> String{
    return s.replacingOccurrences(of: " ", with: "%20")
}
