//
//  ConvertDataToArray.swift
//  Managers
//
//  Created by Tara Tandel on 4/3/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import Foundation
import UIKit
extension Collection where Iterator.Element == [String:Any?] {
    func toJSONString() -> String {
        let arr = self as? [[String : Any?]]
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: arr!, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return JSONString
            }
        }
        catch {
            print("somthing")
        }
        
        return "[]"
    }
    
    
}

