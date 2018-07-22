//
//  ArticleParser.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import Foundation
import WikipediaKit
import SwiftSoup

typealias WikiArticleCompletion = (_ article: WikiArticle?, _ isSuccessful: Bool) -> ()

class ArticleParser: NSObject {
    
    var completion: WikiArticleCompletion?
    let language = WikipediaLanguage("en")
    var randomTime: Date{
        let randomNumber: Int = Int(arc4random_uniform(UInt32(240)))
        let date = Date(timeIntervalSinceNow: TimeInterval(-60 * 60 * randomNumber))
        return date
    }
    var imageURL: URL?
    var title: String?
    var totalString: String = ""
    
    
    func requestWikiArticle(completion: @escaping WikiArticleCompletion) {
        
        WikipediaNetworking.appAuthorEmailForAPI = Constants.emailId
        self.completion = completion
        self.searchRandomTitle()
        
    }
    
    private func searchRandomTitle() {
        
        _ = Wikipedia.shared.requestMostReadArticles(language: language, date: randomTime, completion: {[weak self] (articles, date, language, error) in
            
            guard let articlePreviews = articles else{
                self?.completion?(nil,false)
                return
            }
            let randomNumber: Int = Int(arc4random_uniform(UInt32(articlePreviews.count - 1)))
            self?.requestArticle(title: articlePreviews[randomNumber].displayTitle)
//            self?.requestArticle(title: "Skyscraper (2018 film)")
        })
        
    }
    
    private func requestArticle(title: String?) -> Void {
        
        let language = WikipediaLanguage("en")
        let _ = Wikipedia.shared.requestArticle(language: language, title: title ?? Constants.defaultArticle , imageWidth: 720) {[weak self] (article, error) in
            guard error == nil else {
                self?.completion?(nil,false)
                return
            }
            guard let article = article else {
                self?.completion?(nil,false)
                return
                
            }
            
            let text = article.rawText.replacingOccurrences(of: "<table[^>]*?>[\\s\\S]*?</table>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "<div class=\"reflist.*\" [^>]*?>[\\s\\S]*?</div>", with: "", options: .regularExpression, range: nil).components(separatedBy: "<h2>")
            self?.title = article.displayTitle
            self?.imageURL = article.imageURL
            self?.parseHTML(textArr: text)
            print("----------------------\n\n\n")
        }
    }
    
    private func parseHTML(textArr: [String]) -> Void {

        var list: [WikiElements] = []
        
        do {
            for text in textArr{
                
                let t1 = text.components(separatedBy: "</h2>")
                
                if t1.count == 1{
                    let doc = try SwiftSoup.parse(t1[0]).text().replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression, range: nil)
                    
                    let title = try SwiftSoup.parse(self.title!).text()
                    totalString += doc
                    self.title = title
                    let wikiElement = WikiElements(with: title, body: doc)
                    
                    list.append(wikiElement)
                }else{
                    
                    var header: String?
                    var body: String?
                    
                    for t in t1{
                        
                        
                        
                        
                        let doc = try SwiftSoup.parse(t).text()
                        
                        if (header == nil){
                            header = doc.replacingOccurrences(of: "\\[.*\\]", with: "", options: .regularExpression, range: nil)
                        }else if body == nil{
                            let text = doc.replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression, range: nil)
                            body = text
                            
                            if text.count < 20{
                                body = nil
                            }
                            
                            if text.count > 10000{
                                body = substringToLastFullStop(text1: String(text.prefix(10000)))
                            }
                            
                            totalString += (body ?? "")
                            
                        }
                        
                    }
                    
                    if let header = header, let body = body, !header.isEmpty, !body.isEmpty, !Constants.excludingTitles.contains(header){
                        let wikiElement = WikiElements(with: header, body: body)
                        
                        list.append(wikiElement)
                    }
                    
                }
                
                if totalString.count > Constants.totalCharactersCount{
                    break
                }
                
            }
            
            
            
            let wikiArticle = WikiArticle(with: title, imageURL: imageURL, wikiElements: list)
            wikiArticle.totalString = totalString
            self.completion?(wikiArticle,true)
        } catch {
            self.completion?(nil,false)
        }
        
    }
    
    func substringToLastFullStop(text1: String) -> String {
        var text = text1
        if let range = text.range(of: ".", options: .backwards, range: nil, locale: nil){
            
            text = String(text.prefix(upTo: range.lowerBound)) + "."
            
        }
        return text
    }
    

}
