//
//  ViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 18/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import WikipediaKit


class ViewController: UIViewController {
    let wikipedia = Wikipedia()
    
    
    
    @IBOutlet weak var displayLBL: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WikipediaNetworking.appAuthorEmailForAPI = "abhirocketmail@gmail.com"
        
        Wikipedia.sharedFormattingDelegate = self
        let language = WikipediaLanguage("en")
        
//        _ = Wikipedia.shared.requestSingleRandomArticle(language: language, maxCount: 8, imageWidth: 640) {
//            (article, language, error) in
//
//            guard let article = article else { return }
//
//            print(article.displayTitle)
//        }
//
        _ = Wikipedia.shared.requestRandomArticles(language: language, imageWidth: 0, completion: { (article, lang, error) in
            guard let article = article else { return }
            print(article.first?.displayTitle)
            self.requestArticle(title: article.first?.displayTitle)
        })
//        let dayBeforeYesterday = Date(timeIntervalSinceNow: -60 * 60 * 24)
//
//        let _ = Wikipedia.shared.requestMostReadArticles(language: language, date: dayBeforeYesterday) { (articlePreviews, date, resultsLanguage, error) in
//
//            guard error == nil else { return }
//            guard let articlePreviews = articlePreviews else { return }
//
//            let randomNumber: Int = Int(arc4random_uniform(UInt32(articlePreviews.count - 1)))
////
//            self.requestArticle(title: articlePreviews[randomNumber].displayTitle)
////            for a in articlePreviews {
////                print(a.displayTitle)
////            }
//        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func requestArticle(title: String?) -> Void {
        print("\n\n\n - - -- -  \(title)\n\n")
        
        let language = WikipediaLanguage("en")
        let imageWidth = Int(self.view.frame.size.width * UIScreen.main.scale)
        let _ = Wikipedia.shared.requestArticle(language: language, title: title ?? "India", imageWidth: imageWidth) { (article, error) in
            guard error == nil else { return }
            guard let article = article else { return }
            print("----------------------\n\n\n")
            let text = article.rawText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).components(separatedBy: "\n")
            self.processString(textArr: text)
            print(text.count)
//            print(article.rawText)
            print("----------------------\n\n\n")
        }
    }
    
    
    func processString(textArr: Array<String>) {
        
//        var maxStr = ""
//
//        for str in textArr{
//            if str.count > maxStr.count{
//                maxStr = str
//            }
//
//        }
        
        var mxStr = ""
        
        for str in textArr{//.components(separatedBy: "\n"){
            
            if str.count > mxStr.count{
                mxStr = str
            }
            
        }
//        \\[[0-9]+]
        
        DispatchQueue.main.async {
            self.displayLBL.text = mxStr.replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression, range: nil)
        }
        
//        print(mxStr)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


public extension NSString {
    
    public func byConvertingHTMLToPlainText() -> String {
        
        let stopCharacters = CharacterSet(charactersIn: "< \t\n\r\(0x0085)\(0x000C)\(0x2028)\(0x2029)")
        let newLineAndWhitespaceCharacters = CharacterSet(charactersIn: " \t\n\r\(0x0085)\(0x000C)\(0x2028)\(0x2029)")
        let tagNameCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        let result = NSMutableString(capacity: length)
        let scanner = Scanner(string: self as String)
        scanner.charactersToBeSkipped = nil
        scanner.caseSensitive = true
        var str: NSString? = nil
        var tagName: NSString? = nil
        var dontReplaceTagWithSpace = false
        
        repeat {
            // Scan up to the start of a tag or whitespace
            if scanner.scanUpToCharacters(from: stopCharacters, into: &str), let s = str {
                result.append(s as String)
                str = nil
            }
            // Check if we've stopped at a tag/comment or whitespace
            if scanner.scanString("<", into: nil) {
                // Stopped at a comment, script tag, or other tag
                if scanner.scanString("!--", into: nil) {
                    // Comment
                    scanner.scanUpTo("-->", into: nil)
                    scanner.scanString("-->", into: nil)
                } else if scanner.scanString("script", into: nil) {
                    // Script tag where things don't need escaping!
                    scanner.scanUpTo("</script>", into: nil)
                    scanner.scanString("</script>", into: nil)
                } else {
                    // Tag - remove and replace with space unless it's
                    // a closing inline tag then dont replace with a space
                    if scanner.scanString("/", into: nil) {
                        // Closing tag - replace with space unless it's inline
                        tagName = nil
                        dontReplaceTagWithSpace = false
                        if scanner.scanCharacters(from: tagNameCharacters, into: &tagName), let t = tagName {
                            tagName = t.lowercased as NSString
                            dontReplaceTagWithSpace =
                                tagName == "a" ||
                                tagName == "b" ||
                                tagName == "i" ||
                                tagName == "q" ||
                                tagName == "span" ||
                                tagName == "em" ||
                                tagName == "strong" ||
                                tagName == "cite" ||
                                tagName == "abbr" ||
                                tagName == "acronym" ||
                                tagName == "label"
                        }
                        // Replace tag with string unless it was an inline
                        if !dontReplaceTagWithSpace && result.length > 0 && !scanner.isAtEnd {
                            result.append(" ")
                        }
                    }
                    // Scan past tag
                    scanner.scanUpTo(">", into: nil)
                    scanner.scanString(">", into: nil)
                }
            } else {
                // Stopped at whitespace - replace all whitespace and newlines with a space
                if scanner.scanCharacters(from: newLineAndWhitespaceCharacters, into: nil) {
                    if result.length > 0 && !scanner.isAtEnd {
                        result.append(" ") // Dont append space to beginning or end of result
                    }
                }
            }
        } while !scanner.isAtEnd
        
        // Cleanup
        
        // Decode HTML entities and return (this isn't included in this gist, but is often important)
        // let retString = (result as String).stringByDecodingHTMLEntities
        
        // Return
        return result as String // retString;
    }
    
}

extension ViewController: WikipediaTextFormattingDelegate{
    func format(context: WikipediaTextFormattingDelegateContext, rawText: String, title: String?, language: WikipediaLanguage, isHTML: Bool) -> String {
//        print(rawText)
        return rawText
    }
    
    
    
}

