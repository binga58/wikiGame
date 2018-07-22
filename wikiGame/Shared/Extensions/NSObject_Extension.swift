//
//  NSObject_Extension.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import Foundation

extension NSObject
{
    static func className() -> String{
        return String(describing : self)
    }
}
