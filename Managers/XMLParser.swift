//
//  File.swift
//  Managers
//
//  Created by Tara Tandel on 4/3/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyXMLParser
fileprivate var parsedXMLString: String?
fileprivate var parsedElementValue: String?
extension ViewController: XMLParserDelegate {
    
    

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "string" {
            parsedElementValue = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        parsedElementValue?.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "string" {
            parsedXMLString = parsedElementValue
            parsedElementValue = nil
        }
    }
}

