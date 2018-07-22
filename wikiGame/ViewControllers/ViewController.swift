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
                print(self?.wikiArticle)
                DispatchQueue.main.async {
                    self?.gameTableView.reloadData()
                }
                
            }else {
                self?.requestArticle()
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
            
            cell?.configure(wikiElement: wikiArticle?.elements?.first)
            
            return cell ?? IntroParaTableViewCell()
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphTableViewCell.className()) as? ParagraphTableViewCell
            
            cell?.configure(wikiElement: wikiArticle?.elements?[indexPath.row - 1])
            
            return cell ?? ParagraphTableViewCell()
        }
    }
    
    
    
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

