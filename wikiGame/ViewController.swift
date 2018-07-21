//
//  ViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 18/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import WikipediaKit
import SwiftSoup
import Kanna

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


class ViewController: UIViewController {
    let wikipedia = Wikipedia()
    
    
    
    @IBOutlet weak var displayLBL: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(set)
        
        WikipediaNetworking.appAuthorEmailForAPI = "abhirocketmail@gmail.com"
        
//        Wikipedia.sharedFormattingDelegate = self
        let language = WikipediaLanguage("en")
        
//        _ = Wikipedia.shared.requestSingleRandomArticle(language: language, maxCount: 8, imageWidth: 640) {
//            (article, language, error) in
//
//            guard let article = article else { return }
//
////            self.requestArticle(title: "India")
//
//            self.requestArticle(title: article.displayTitle)
//
//        }
        
        let dateBeforeYesterday = Date(timeIntervalSinceNow: -60 * 60 * 72)
        
        _ = Wikipedia.shared.requestMostReadArticles(language: language, date: dateBeforeYesterday, completion: { (articles, date, language, error) in
            
            guard let articlePreviews = articles else{return}
            let randomNumber: Int = Int(arc4random_uniform(UInt32(articlePreviews.count - 1)))

            
            self.requestArticle(title: articlePreviews[randomNumber].displayTitle)
            
        })
        
    }
    
    func requestArticle(title: String?) -> Void {
        print("\n\n\n - - -- -  \(String(describing: title))\n\n")
        
        let language = WikipediaLanguage("en")
        let imageWidth = Int(self.view.frame.size.width * UIScreen.main.scale)
        let _ = Wikipedia.shared.requestArticle(language: language, title: title ?? "India", imageWidth: imageWidth) { (article, error) in
            guard error == nil else { return }
            guard let article = article else { return }
            print("----------------------\n\n\n")
            
            let text = article.rawText.replacingOccurrences(of: "<table[^>]*?>[\\s\\S]*?</table>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "<div class=\"reflist.*\" [^>]*?>[\\s\\S]*?</div>", with: "", options: .regularExpression, range: nil).components(separatedBy: "<h2>")
            self.processHTML(textArr: text, title: article.displayTitle)
            print("----------------------\n\n\n")
        }
    }
    
    func processHTML(textArr: [String], title: String) -> Void {
        
        var list: [WikiElements] = []
        
        do {
            for text in textArr{
                
                let t1 = text.components(separatedBy: "</h2>")
                
                
                
                if t1.count == 1{
                    let doc = try SwiftSoup.parse(t1[0]).text()
                    
                    let wikiElement = WikiElements(with: title, body: doc)
                    
                    list.append(wikiElement)
                }else{
                    
                    var header: String?
                    var body: String?
                    
                    for t in t1{
                        
                        let doc = try SwiftSoup.parse(t).text().replacingOccurrences(of: "\\[.*\\]", with: "", options: .regularExpression, range: nil)
                        
                        if (header == nil){
                            header = doc
                        }else if body == nil{
                            body = doc
                        }
                        
                    }
                    
                    if let header = header, let body = body, !header.isEmpty, !body.isEmpty{
                        let wikiElement = WikiElements(with: header, body: body)
                        
                        list.append(wikiElement)
                    }

                }
            }
            
            
            print(list)
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        
    }
    
    
    func processString(textArr: String) {
        
        
        DispatchQueue.main.async {
            self.displayLBL.text = textArr
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
