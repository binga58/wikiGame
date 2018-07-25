//
//  WikiArticle.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

class WikiArticle: NSObject {
    
    var title: String?
    var imageURL: URL?
    var elements: [WikiElements]?
    var totalString: String?
    
    init(with title: String?, imageURL: URL?, wikiElements: [WikiElements]) {
        self.title = title
        self.imageURL = imageURL
        self.elements = wikiElements
    }
    
    override var description: String{
        return "\n===========\n\(String(describing: self.title))\n------------\(String(describing: self.imageURL))\n-----------------\(String(describing: self.elements))\n=================="
    }
    
    
    
}

class WikiElements: NSObject {
    var title: String?
    var body: String?
    var attributedText: NSAttributedString?
    
    init(with title: String?, body: String?) {
        self.title = title
        self.body = body
    }
    
    override var description: String{
        return "\n===========\n\(String(describing: self.title))\n------------\(String(describing: self.body))\n=================="
    }
}


struct Options:Hashable{
    var index:Int
    var value:String
    var line:Int
    
    init(index:Int,value:String,line:Int) {
        self.index = index
        self.value = value
        self.line = line
    }
    
    var hashValue: Int {
        return line.hashValue
    }
    
    static func == (lhs: Options, rhs: Options) -> Bool {
        return (lhs.line == rhs.line && lhs.index == rhs.index)
    }
    
}
