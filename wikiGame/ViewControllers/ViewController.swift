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
    var correctOptions: [Options] = []
    var userSelectedOption: [Options] = []
    
    
    var currentSelectedOption: Options?
    
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
            let strArray = strTest.components(separatedBy: ".")
            
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
            
            var randomLineSet: Set<Int> = Set()
            
            for i in stride(from: 0, to: 10, by: 1){
                randomLineSet.insert(i)
            }
            
            for (lineNumber, line) in strArray.enumerated(){
                
                
                if lineNumber < 10 {
                    
                    let words = line.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").compactMap { (oldValue) -> String? in
                        return oldValue.replacingOccurrences(of: " ", with: "")
                    }
                    
                    
                    let count = UInt32(words.count)
                    let randomIndex = Int(arc4random_uniform(count))
                    
                    let lineTextNSMutableAttributedString = NSMutableAttributedString.init(string: " ")
                    
                    for (index, word) in words.enumerated() {
                        
                        if word.count > 0{
                            if index == randomIndex{
                                
                                let option = Options(index: index, value: word, line: lineNumber)
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: Constants.blankString + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - Constants.blankString.count - 1, length: Constants.blankString.count))
                                
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
            
            paraText.addAttributes(attributes, range: NSMakeRange(0, paraText.length))
            
            correctOptions.shuffle()
            
            self.wikiArticle?.elements?.first?.attributedText = paraText
            
        }
        
    }
    
    func resetTextView(option:Options){
        
        if let strTest = self.wikiArticle?.elements?.first?.attributedText?.string{
            
            
            let paraText:NSMutableAttributedString = NSMutableAttributedString.init(string: "")
            let strArray = strTest.components(separatedBy: ".")
            
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText, NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Light", size: 17.0)!]
            
            for (lineNumber, line) in strArray.enumerated(){
                
                if lineNumber < 10 {
                    
                    let words = line.components(separatedBy: " ")
                    
                    let lineTextNSMutableAttributedString = NSMutableAttributedString.init(string: " ")
                    
                    for (index, word) in words.enumerated(){
                        
                        if correctOptions.contains(Options(index: index, value: word, line: lineNumber)) {
                            
                            if index == option.index{
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: option.value + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - option.value.count - 1, length: option.value.count))
                            }else {
                                
                                lineTextNSMutableAttributedString.append(NSAttributedString(string: word + (index == words.count - 1 ? "" : " ")))
                                
                                lineTextNSMutableAttributedString.addAttribute(.link, value: "\(lineNumber)-\(index)", range: NSRange(location: lineTextNSMutableAttributedString.length - word.count - 1, length: word.count))
                                
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
            
            paraText.addAttributes(attributes, range: NSMakeRange(0, paraText.length))
            if userSelectedOption.contains(option), let index = userSelectedOption.index(of: option){
                userSelectedOption.remove(at: Int(index))
            }
            userSelectedOption.append(option)
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
        
        let indexes = url.absoluteString.components(separatedBy: "-")
        var lineNumber: Int?
        var wordIndex: Int?
        
        for (i, index) in indexes.enumerated(){
            if i == 0{
                lineNumber = Int(index)
            }else{
                wordIndex = Int(index)
            }
        }
        
        if let lineNumber = lineNumber, let wordIndex = wordIndex{
            currentSelectedOption = Options(index: wordIndex, value: Constants.blankString, line: lineNumber)
        }
        picker?.show()
    }
    
}

extension ViewController: CZPickerViewDataSource{
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return correctOptions.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, attributedTitleForRow row: Int) -> NSAttributedString! {
        return NSAttributedString(string: correctOptions[row].value)
    }
    
}

extension ViewController: CZPickerViewDelegate{
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        let option = correctOptions[row]
        if let lineNumber = currentSelectedOption?.line, let wordIndex = currentSelectedOption?.index{
            let selectedOption = Options(index: wordIndex, value: option.value, line: lineNumber)
            self.resetTextView(option: selectedOption)
        }
        
        
        
    }
    
    
}





