//
//  StringExtension.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 26/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import Foundation

extension String{
    
    public func urlEncoded() -> String {
        let string = self
        
        var characterSet = NSMutableCharacterSet.urlQueryAllowed
        
        let delimitersToEncode = ":#[]@!$?&'()*+="
        characterSet.remove(charactersIn: delimitersToEncode)
        
        return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet) ?? string
    }
    
    
}
