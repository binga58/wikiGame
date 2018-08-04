//
//  WikiArticle.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

struct Option:Hashable{
    var index:Int
    var value:String
    var line:Int
    var isMarkedCorrect: Bool = false
    
    init(index:Int,value:String,line:Int) {
        self.index = index
        self.value = value
        self.line = line
    }
    
    var hashValue: Int {
        return line.hashValue
    }
    
    static func == (lhs: Option, rhs: Option) -> Bool {
        return (lhs.line == rhs.line && lhs.index == rhs.index)
    }
    
    mutating func markOptionCorrect() {
        self.isMarkedCorrect = true
    }
    
}

struct Article: Codable {
    var name: String
    var rank: Int
    
    init(name: String, rank: Int) {
        self.rank = rank
        self.name = name
    }
}
