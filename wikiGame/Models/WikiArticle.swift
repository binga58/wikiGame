//
//  WikArt.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 26/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import Foundation
import SwiftSoup

class WikiArticle {
    
    public var title: String
    public var body: String
    public var imageURL: URL?
    public var description: String?
    public var attributedText: NSMutableAttributedString?
    public var correctOptions: [Option]
    public var userSelectedOptions: [Option]
    public var tempOption: Option?
    let fontTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
    
    public init(title: String) {
        
        self.title = title
        self.body = ""
        self.correctOptions = []
        self.userSelectedOptions = []
    }
    
    
    
}

extension WikiArticle{
    
    public convenience init?(dict: JSONDictionary) {
        guard let mobileview = dict[APIKey.mobileView] as? JSONDictionary,
            let sections = mobileview[APIKey.sections] as? [JSONDictionary],
        let title = mobileview[APIKey.displaytitle] as? String
            else {
                return nil
        }
        self.init(title: title)
        
        do{
            let text = try SwiftSoup.parse(title).text()
            
            self.title = text
            
        }catch {
            print(error)
        }
        
        if let thumbProperties = mobileview[APIKey.thumb] as? JSONDictionary,
            let imageURLString = thumbProperties[APIKey.url] as? String,
            var imageURL = URL(string: imageURLString) {
            if var urlComponents = URLComponents(url: imageURL, resolvingAgainstBaseURL: false),
                urlComponents.scheme == nil {
                urlComponents.scheme = "https"
                imageURL = urlComponents.url ?? imageURL
            }
            self.imageURL = imageURL
        }
        
        if let description = mobileview[APIKey.description] as? String{
            self.description = description
        }
        
        for para in sections{
        
            if let body = para[APIKey.text] as? String, let id = para[APIKey.id] as? Int{
                
                
                if id == 0{
                    
                    do{
                        let text = try SwiftSoup.parse(body).text().replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression, range: nil)
                        
                        self.body += text
                        
                        let textArr = self.body.components(separatedBy: ".")
                        
                        if textArr.count >= Constants.minimumLines{
                            break
                        }
                        
                    }catch {
                        print(error)
                    }

                    
                }else {
                    
                    if let tocLevel = para[APIKey.toclevel] as? Int{
                        
                        if tocLevel == 2{
                            
                            let textArr = body.components(separatedBy: "</h2>")
                            
                            if textArr.count == 2, let paragraph = textArr.last {
                                
                                do{
                                    let text = try SwiftSoup.parse(paragraph).text().replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression, range: nil)
                                    
                                    self.body += text
                                    
                                    let textArr = self.body.components(separatedBy: ".")
                                    
                                    if textArr.count >= Constants.minimumLines{
                                        break
                                    }
                                    
                                }catch {
                                    print(error)
                                }

                                
                            }
                            
                            
                        } else {
                            continue
                        }
                        
                    }
                    
                }
                
            }
            
        }
    
        
    }
    
    
}

extension WikiArticle{
    
    func createMissingWords() {
        
            let paraText:NSMutableAttributedString = NSMutableAttributedString.init(string: "")
            let strArray = self.body.components(separatedBy: ".").filter { (line) -> Bool in
                return line.count > 1
            }
            
            for (lineNumber, line) in strArray.enumerated(){
                
                
                if lineNumber < Constants.minimumLines {
                    
                    let words = line.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").compactMap { (oldValue) -> String? in
                        return oldValue.replacingOccurrences(of: " ", with: "")
                    }
                    
                    let count = UInt32(words.count)
                    let randomIndex = Int(arc4random_uniform(count))
                    
                    let lineTextNSMutableAttributedString = NSMutableAttributedString.init(string: "")
                    
                    for (index, word) in words.enumerated() {
                        
                        if word.count > 0{
                            if index == randomIndex{
                                
                                let option = Option(index: index, value: word, line: lineNumber)
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: Constants.blankString + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - Constants.blankString.count - (index == words.count - 1 ? 0 : 1), length: Constants.blankString.count))
                                
                                
                                
                                correctOptions.append(option)
                                
                                
                                
                            }else{
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: word + (index == words.count - 1 ? "" : " ")))
                                
                            }
                        }
                    }
                    
                    paraText.append(lineTextNSMutableAttributedString)
                    
                } else{
                    
                    paraText.append(NSAttributedString(string: line))
                    
                }
                
                paraText.append(NSAttributedString(string: "."))
                
                
            }
            
            paraText.addAttributes(fontTextAttributes, range: NSMakeRange(0, paraText.length))
            
            correctOptions.shuffle()
        
            self.attributedText = paraText
            
        }
    
    
    
    func resetTextView(option:Option){
        
        if let strTest = self.attributedText?.string{
            
            
            let paraText:NSMutableAttributedString = NSMutableAttributedString.init(string: "")
            let strArray = strTest.components(separatedBy: ".").filter { (line) -> Bool in
                return line.count > 0
            }
            
            for (lineNumber, line) in strArray.enumerated(){
                
                if lineNumber < Constants.minimumLines {
                    
                    let words = line.components(separatedBy: " ")
                    
                    let lineTextNSMutableAttributedString = NSMutableAttributedString.init(string: "")
                    
                    for (index, word) in words.enumerated(){
                        
                        if correctOptions.contains(Option(index: index, value: word, line: lineNumber)) {
                            
                            if index == option.index && lineNumber == option.line{
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: option.value + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - option.value.count - (index == words.count - 1 ? 0 : 1), length: option.value.count))
                            }else {
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: word + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - word.count - (index == words.count - 1 ? 0 : 1), length: word.count))
                                
                            }
                            
                        }else {
                            
                            lineTextNSMutableAttributedString.append(NSAttributedString(string: word + (index == words.count - 1 ? "" : " ")))
                            
                        }
                        
                    }
                    
                    paraText.append(lineTextNSMutableAttributedString)
                    
                } else{
                    
                    paraText.append(NSAttributedString(string: line))
                    
                }
                
                paraText.append(NSAttributedString(string: "."))
                
            }
            
            paraText.addAttributes(fontTextAttributes, range: NSMakeRange(0, paraText.length))
            if userSelectedOptions.contains(option), let index = userSelectedOptions.index(of: option){
                userSelectedOptions.remove(at: Int(index))
            }
            userSelectedOptions.append(option)
            self.attributedText = paraText
            
        }
    }
    
    
    func findUserScore() -> Int {
        correctOptions.sort { (option1, option2) -> Bool in
            return option1.line < option2.line
        }
        
        userSelectedOptions.sort { (option1, option2) -> Bool in
            return option1.line < option2.line
        }
        
        var points = 0
        
        for (index, option) in userSelectedOptions.enumerated(){
            
            let correctOption = correctOptions[index]
            
            if correctOption.value == option.value{
                points += 1
            }
            
        }
        
        return points
    }
    
    
}
