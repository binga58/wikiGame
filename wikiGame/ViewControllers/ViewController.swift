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

class ViewController: UIViewController {
    let wikipedia = Wikipedia()
    var heightDict: Dictionary<IndexPath,CGFloat> = [:]
    var missingWordsDict: Dictionary<String,Array<Range<String.Index>>> = [:]
    @IBOutlet weak var gameTableView: UITableView!
    var wikiArticle: WikiArticle?
    var articleParser: ArticleParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        requestArticle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}

//MARK:- UI Helper
extension ViewController {
    
    func setupView() {
        
        
        gameTableView.register(UINib(nibName: ParagraphTableViewCell.className(), bundle: nil), forCellReuseIdentifier: ParagraphTableViewCell.className())
        
        gameTableView.register(UINib(nibName: IntroParaTableViewCell.className(), bundle: nil), forCellReuseIdentifier: IntroParaTableViewCell.className())
        
        gameTableView.register(UINib(nibName: HeaderImageTableViewCell.className(), bundle: nil), forCellReuseIdentifier: HeaderImageTableViewCell.className())
        //
    }
    
}

extension ViewController{
    
    func requestArticle() {
        
        articleParser = ArticleParser()
        
        articleParser?.requestWikiArticle {[weak self] (article, isSuccessful) in
            if isSuccessful{
                self?.wikiArticle = article
                
                self?.createMissingWords()
                
                DispatchQueue.main.async {
                    self?.gameTableView.reloadData()
                }
                
            }else {
                self?.requestArticle()
            }
        }
        
    }
    
    
    func createMissingWords() {
        
        if let text = self.wikiArticle?.totalString {
            
            let components = text.components(separatedBy: .whitespaces)
            
            var missingWordsSet: Set<String> = Set()
            var maxWordCount = 0
            var sequence = [MissingWords]()
            
            while missingWordsSet.count < 10{
                let randomNumber: Int = Int(arc4random_uniform(UInt32(components.count - 1)))
                let missingWord = components[randomNumber]
                if missingWord.count > maxWordCount{
                    maxWordCount = missingWord.count
                }
                
                let testWord = MissingWords(with: missingWord, count: randomNumber)
                sequence.append(testWord)
                missingWordsSet.insert(missingWord)
            }
            sequence.sort { (firstWord, secondWord) -> Bool in
                if let firstCount = firstWord.count, let secondCount = secondWord.count{
                    return firstCount < secondCount
                }
                
                return false
            }
            print(sequence)
            var line = " "
            for _ in stride(from: 0, to: maxWordCount, by: 1){
                line += "_"
            }
            
            print(missingWordsSet)
            
            for word in Array(missingWordsSet){
                let modifiedWord = " \(word)"
                for element in wikiArticle?.elements ?? []{
                    
                    if let range = element.body?.range(of: modifiedWord){
                        
                        
                        element.body =  element.body?.replacingOccurrences(of: word, with: line, options: .backwards, range: range)
                        
                        if let body = element.body, var arr = missingWordsDict[body]{
                            arr.append(range)
                            missingWordsDict[body] = arr
                        }else{
                            
                            if let body = element.body{
                                
                                var arr: Array<Range<String.Index>> = []
                                arr.append(range)
                                missingWordsDict[body] = arr
                            }
                            
                        }
                        break
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let elements = wikiArticle?.elements{
            return elements.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        return UITableViewCell()
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderImageTableViewCell.className()) as? HeaderImageTableViewCell
            
            cell?.configure(title: wikiArticle?.title, imageURL: wikiArticle?.imageURL)
            
            return cell ?? HeaderImageTableViewCell()
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: IntroParaTableViewCell.className()) as? IntroParaTableViewCell
            
            if let body = wikiArticle?.elements?.first?.body, let arr = missingWordsDict[body]{
                cell?.configure(wikiElement: wikiArticle?.elements?.first,arr: arr)
                
            }
            
            return cell ?? IntroParaTableViewCell()
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphTableViewCell.className()) as? ParagraphTableViewCell
            if let body = wikiArticle?.elements?[indexPath.row - 1].body, let arr = missingWordsDict[body]{
                cell?.configure(wikiElement: wikiArticle?.elements?.first,arr: arr)
                
            }
            
            return cell ?? ParagraphTableViewCell()
        }
    }
    
    
    
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

