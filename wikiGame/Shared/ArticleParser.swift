//
//  ArticleParser.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import Foundation
import SwiftSoup

typealias WikiArticleCompletion = (_ article: WikiArticle?, _ isSuccessful: Bool) -> ()

class ArticleParser: NSObject {
    
    static let shared = ArticleParser()
    var completion: WikiArticleCompletion?
    var randomTime: Date{
        let randomNumber: Int = Int(arc4random_uniform(UInt32(240)))
        let date = Date(timeIntervalSinceNow: TimeInterval(-60 * 60 * randomNumber))
        return date
    }
    var articleList: [Article] = []
    
    func requestWikiArticle(completion: @escaping WikiArticleCompletion) {
        
        self.completion = completion
        self.searchRandomTitle()
        
    }
    
    private func mostReadArticleURL() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let dateString = dateFormatter.string(from: randomTime)
        
        let urlString = "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia.org/all-access/" + dateString
        
        return urlString
    }
    
    func wikiTitleURL(title: String) -> String {
        
        let parameters: [String:String] = [
            "action": "mobileview",
            "format": "json",
            "page": title,
            "mobileformat": "1",
            "prop": "id|text|sections|languagecount|displaytitle|description|image|thumb",
            "sections": "all",
            "sectionprop": "toclevel|level|line|anchor",
            "thumbwidth" : "720",
            "redirect": "yes",
            "maxage": "7200",
            "smaxage": "7200",
            "uselang": "en",
            ]
        
        let url = "https://en.wikipedia.org/w/api.php?" + "\(NetworkClass.stringFromQueryParameters(parameters))"
        
        return url
    }
    
    
    private func searchRandomTitle() {
        
        if self.articleList.count > 0{
            
            self.getRandomTitle()
            
        } else{
            
            NetworkClass.sendRequest(url: mostReadArticleURL(),incluedBaseURl: false, requestType: .get, parameters: nil) {[weak self] (status, response, error, statusCode) in
                
                if status, let result = response as? Dictionary<String,AnyObject>, let items = (result[APIKey.items] as? Array<AnyObject>)?.first as? Dictionary<String,AnyObject>, let articles = items[APIKey.articles] as? Array<Dictionary<String,AnyObject>>{
                    
                    self?.articleList = []
                    for articleDict in articles{
                        
                        if let name = articleDict[APIKey.article] as? String, let rank = articleDict[APIKey.rank] as? Int, name != APIKey.mainPage, name != APIKey.specialSearch{
                            let article = Article(name: name, rank: rank)
                            self?.articleList.append(article)
                        }
                        
                    }
                    
                    if (self?.articleList.count ?? 0) > 0 {
                        self?.getRandomTitle()
                    } else{
                        ArticleParser.shared.completion?(nil, false)
                    }
                    
                    
                }else {
                    ArticleParser.shared.completion?(nil, false)
                }
                
            }
            
        }
        
        
    }
    
    func getRandomTitle() {
        
        let randomIndex = Int(arc4random_uniform(UInt32(ArticleParser.shared.articleList.count)))
        
        ArticleParser.shared.requestArticle(title: ArticleParser.shared.articleList[randomIndex].name)
        
        ArticleParser.shared.articleList.remove(at: randomIndex)
        
    }
    
    private func requestArticle(title: String) -> Void {
        
        NetworkClass.sendRequest(url: wikiTitleURL(title: title), incluedBaseURl: false, requestType: .get, parameters: nil) { [weak self] (status, response, error, statusCode) in
            
            if status, let result = response as? JSONDictionary, let wikArt = WikiArticle(dict: result) {
                wikArt.createMissingWords()
                self?.completion?(wikArt, true)
            }else {
                self?.completion?(nil, false)
            }
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
