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
import CZPicker

class ViewController: UIViewController {
    let wikipedia = Wikipedia()
    var heightDict: Dictionary<IndexPath,CGFloat> = [:]
    var missingWordsDict: Dictionary<String,Array<Range<String.Index>>> = [:]
    @IBOutlet weak var gameTableView: UITableView!
    var wikiArticle: WikiArticle?
    var articleParser: ArticleParser?
    var replaceStringSet = Set<Options>()
    var options: [Options] = []
    
    
    var currentSelectedIndex: Int = 0
    
    let picker = CZPickerView(headerTitle: "Options", cancelButtonTitle: "Cancel", confirmButtonTitle: "OK")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        requestArticle()
        
        
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        
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
        
        if let strTest = self.wikiArticle?.elements?.first?.body{
            
            let paraText:NSMutableAttributedString = NSMutableAttributedString.init(string: "")
            var strArray = strTest.components(separatedBy: " ")
            let count = UInt32(strArray.count)
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
            
            while replaceStringSet.count < 10 {
                let number = Int(arc4random_uniform(count))
                if replaceStringSet.insert(Options.init(index: number, value: strArray[number])).inserted{
                    strArray[number] = Constants.blankString
                }
            }
            
            for (index,str) in strArray.enumerated(){
                paraText.append(NSAttributedString.init(string: str + " "))
                if replaceStringSet.contains(Options.init(index: index, value: str)){
                    paraText.addAttribute(.link, value: "\(index)", range: NSRange(location: paraText.length - Constants.blankString.count - 1, length: Constants.blankString.count))
                }
            }
            options = Array(replaceStringSet)
            paraText.addAttributes(attributes, range: NSMakeRange(0, paraText.length))
            
            self.wikiArticle?.elements?.first?.attributedText = paraText
        }
        
    }
    
    func resetTextView(obj:Options){
        
        if let strTest = self.wikiArticle?.elements?.first?.attributedText?.string{
        
        let paraText = NSMutableAttributedString.init(string: "")
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
            var strArray = strTest.components(separatedBy: " ")
        
        for (index,str) in strArray.enumerated(){
            if index == obj.index{
                strArray[index] = obj.value
                paraText.append(NSAttributedString.init(string: obj.value + " "))
//                if replaceStringSet.contains(Options.init(index: index, value: str)){
                    paraText.addAttribute(.link, value: "\(index)", range: NSRange(location: paraText.length - obj.value.count - 1,     length: obj.value.count))
//                }
            }else{
                paraText.append(NSAttributedString.init(string: str + " "))
                if replaceStringSet.contains(Options.init(index: index, value: str)){
                    paraText.addAttribute(.link, value: "\(index)", range: NSRange(location: paraText.length - str.count - 1 , length: str.count))
                }
            }
        }
            paraText.addAttributes(attributes, range: NSMakeRange(0, paraText.length))
        self.wikiArticle?.elements?.first?.attributedText = paraText
            
            DispatchQueue.main.async {[weak self] in
                self?.gameTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            
        }
    }
    
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = wikiArticle?.elements{
            return 2
            
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
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: IntroParaTableViewCell.className()) as? IntroParaTableViewCell
            
            if let _ = wikiArticle?.elements?.first?.attributedText{
                cell?.configure(wikiElement: wikiArticle?.elements?.first)
                
            }
            cell?.delegate = self
            return cell ?? IntroParaTableViewCell()
        }
    }
    
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}


extension ViewController: TextfieldURLInteractionDelegate{
    func interacted(with url: URL, range: NSRange) {
        currentSelectedIndex = Int(url.absoluteString)!
        picker?.show()
    }
    
}

extension ViewController: CZPickerViewDataSource{
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return options.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, attributedTitleForRow row: Int) -> NSAttributedString! {
        return NSAttributedString(string: options[row].value)
    }
    
}

extension ViewController: CZPickerViewDelegate{
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        let option = options[row]
        
        let selectedOption = Options(index: currentSelectedIndex, value: option.value)
        
        self.resetTextView(obj: selectedOption)
        
    }
    
    
}


