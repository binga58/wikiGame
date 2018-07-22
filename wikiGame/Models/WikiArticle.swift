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
    
    init(with title: String?, body: String?) {
        self.title = title
        self.body = body
    }
    
    override var description: String{
        return "\n===========\n\(String(describing: self.title))\n------------\(String(describing: self.body))\n=================="
    }
}
