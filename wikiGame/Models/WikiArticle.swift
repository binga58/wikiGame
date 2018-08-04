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
    public var resultAttributedText: NSMutableAttributedString?
    public var correctOptions: [Option]
    public var userSelectedOptions: [Option]
    public var tempOption: Option?
    let fontTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
    
    let resultTextAttributes = [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
    
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
        
        //Initializing WikiArticle
        self.init(title: title)
        
        do{
            //removing tags from article like <i>
            let text = try SwiftSoup.parse(title).text()
            
            self.title = text
            
        }catch {
            print(error)
        }
        
        //Image URL
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
        
        //Article description
        if let description = mobileview[APIKey.description] as? String{
            self.description = description
        }
        
        //Parsing through sections
        for para in sections{
            
            if let body = para[APIKey.text] as? String, let id = para[APIKey.id] as? Int{
                
                //For Introductory para
                if id == 0{
                    
                    do{
                        //Removing tags and getting only displayed Text
                        //Regex to remove numbers like [21]
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
                    //For further para
                    //Not much tested
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
        
        //Seperating by lines
        let strArray = self.body.components(separatedBy: ".").filter { (line) -> Bool in
            return line.count > 1
        }
        
        for (lineNumber, line) in strArray.enumerated(){
            
            //Missing words for first ten lines
            if lineNumber < Constants.minimumLines {
                
                //Seperating by whitespace
                let words = line.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").compactMap { (oldValue) -> String? in
                    return oldValue.replacingOccurrences(of: " ", with: "")
                }
                
                let count = UInt32(words.count)
                let randomIndex = Int(arc4random_uniform(count))
                
                let lineTextNSMutableAttributedString = NSMutableAttributedString.init(string: "")
                
                //For enumerating the words
                for (index, word) in words.enumerated() {
                    
                    if word.count > 0{
                        //Replacing random word with blank string
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
    
    
    
    func userSelected(option:Option){
        
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
                            
                            //Replacing with user selected word and converting them to link
                            if index == option.index && lineNumber == option.line{
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: option.value + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - option.value.count - (index == words.count - 1 ? 0 : 1), length: option.value.count))
                            }else {
                                //Converting missed words to links
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
    
    func createResult() {
        
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
                        
                        
                        if let option = correctOptions.filter({ $0.index == index && $0.line == lineNumber }).first {
                            
                            
                            lineTextNSMutableAttributedString.append(NSAttributedString(string: option.value + (index == words.count - 1 ? "" : " ")))
                            let attr = [NSAttributedStringKey.foregroundColor: option.isMarkedCorrect ? UIColor.correct : UIColor.wrong]
                            lineTextNSMutableAttributedString.addAttributes(attr, range: NSRange(location: lineTextNSMutableAttributedString.length - option.value.count - (index == words.count - 1 ? 0 : 1), length: option.value.count))
                            
                            
                        } else {
                            
                            lineTextNSMutableAttributedString.append(NSAttributedString(string: word + (index == words.count - 1 ? "" : " ")))
                            
                        }
                        
                    }
                    
                    paraText.append(lineTextNSMutableAttributedString)
                    
                } else{
                    
                    paraText.append(NSAttributedString(string: line))
                    
                }
                
                paraText.append(NSAttributedString(string: "."))
                
            }
            
            paraText.addAttributes(resultTextAttributes, range: NSMakeRange(0, paraText.length))
            
            self.resultAttributedText = paraText
            
        }
        
    }
    
    
    //User score
    func findUserScore() -> Int {
        correctOptions.sort { (option1, option2) -> Bool in
            return option1.line < option2.line
        }
        
        userSelectedOptions.sort { (option1, option2) -> Bool in
            return option1.line < option2.line
        }
        
        var points = 0
        
        for (index, option) in userSelectedOptions.enumerated(){
            
            var correctOption = correctOptions[index]
            
            if correctOption.value.lowercased() == option.value.lowercased(){
                points += 1
                correctOption.markOptionCorrect()
                correctOptions[index] = correctOption
            }
            
        }
        
        createResult()
        
        return points
    }
    
    
}

