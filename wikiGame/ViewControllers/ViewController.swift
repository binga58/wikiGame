//
//  ViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 18/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import SwiftSoup
import CZPicker

class ViewController: UIViewController {
    var heightDict: Dictionary<IndexPath,CGFloat> = [:]
    @IBOutlet weak var gameTableView: UITableView!
    var wikiArticle: WikiArticle?
    
    let picker = CZPickerView(headerTitle: "Options", cancelButtonTitle: "Cancel", confirmButtonTitle: "OK")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        requestArticle()
        
        
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        
    }
    
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {

        
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
        
        gameTableView.register(UINib(nibName: IntroParaTableViewCell.className(), bundle: nil), forCellReuseIdentifier: IntroParaTableViewCell.className())
        
        gameTableView.register(UINib(nibName: HeaderImageTableViewCell.className(), bundle: nil), forCellReuseIdentifier: HeaderImageTableViewCell.className())
        
    }
    
}

extension ViewController{
    
    func requestArticle() {
        
        
        
        ArticleParser.shared.requestWikiArticle {[weak self] (article, isSuccessful) in
            if isSuccessful{
                self?.wikiArticle = article
                
                DispatchQueue.main.async {
                    self?.gameTableView.reloadData()
                }
                
            }else {
                if NetworkClass.isConnected(){
                    self?.requestArticle()
                }
            }
        }
        
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = wikiArticle{
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
            
            if let _ = wikiArticle?.attributedText{
                cell?.configure(text: wikiArticle?.attributedText)
                
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
        if indexes.count > 1{
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
                wikiArticle?.tempOption = Option(index: wordIndex, value: Constants.blankString, line: lineNumber)
            }
            
            
            
            if let option = wikiArticle?.tempOption, let userSelectedOption = wikiArticle?.userSelectedOptions, let selectedOption = userSelectedOption.index(of: option), let index = wikiArticle?.correctOptions.index(where: {$0.value == userSelectedOption[Int(selectedOption)].value}) {
                picker?.setSelectedRows([Int(index)])
            }else{
                picker?.unselectAll()
            }
            
            
            
            picker?.show()
        }
        
    }
    
}

extension ViewController: CZPickerViewDataSource{
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return wikiArticle?.correctOptions.count ?? 0
    }
    
    func czpickerView(_ pickerView: CZPickerView!, attributedTitleForRow row: Int) -> NSAttributedString! {
        return NSAttributedString(string: wikiArticle?.correctOptions[row].value ?? "")
    }
}

extension ViewController: CZPickerViewDelegate{
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        
        if let option = wikiArticle?.correctOptions[row], let lineNumber = wikiArticle?.tempOption?.line, let wordIndex = wikiArticle?.tempOption?.index{
            let selectedOption = Option(index: wordIndex, value: option.value, line: lineNumber)
            wikiArticle?.resetTextView(option: selectedOption)
            
            DispatchQueue.main.async {[weak self] in
                if let cell = self?.gameTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? IntroParaTableViewCell{
                    cell.configure(text: self?.wikiArticle?.attributedText)
                }
            }
            
        }
    }
    
    
}





