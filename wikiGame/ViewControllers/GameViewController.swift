//
//  GameViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 18/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import SwiftSoup
import CZPicker

class GameViewController: UIViewController {
    var heightDict: Dictionary<IndexPath,CGFloat> = [:]
    @IBOutlet weak var gameTableView: UITableView!
    var wikiArticle: WikiArticle?
    
    let picker = CZPickerView(headerTitle: Constants.options, cancelButtonTitle: Constants.cancel, confirmButtonTitle: Constants.ok)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        DispatchQueue.main.async {
            self.gameTableView.setContentOffset(.zero, animated: false)
        }
    }
    
}

//MARK:- UI Helper
extension GameViewController {
    
    func setupView() {
        
        //Navigation title
        setNavigationBarWithTitle(title: Constants.wikiGame, LeftButtonType: .none, RightButtonType: .done)
        
        //Cell registration
        gameTableView.register(UINib(nibName: IntroParaTableViewCell.className(), bundle: nil), forCellReuseIdentifier: IntroParaTableViewCell.className())
        
        gameTableView.register(UINib(nibName: HeaderImageTableViewCell.className(), bundle: nil), forCellReuseIdentifier: HeaderImageTableViewCell.className())
        
        
        //Picker view configuration
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        picker?.headerBackgroundColor = UIColor.white
        picker?.headerTitleColor = UIColor.black
        picker?.confirmButtonBackgroundColor = UIColor.theme
        
        
    }
    
}

//MARK:- TableView datasource
extension GameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = wikiArticle{
            return 2
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

//MARK:- Table view Delegate
extension GameViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

//MARK:- TextfieldURLInteractionDelegate
extension GameViewController: TextfieldURLInteractionDelegate{
    func interacted(with url: URL, range: NSRange) {
        //Get the line number and index of word seperated by -
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
            
            //Create temporary option to store users selected index and line number
            if let lineNumber = lineNumber, let wordIndex = wordIndex{
                wikiArticle?.tempOption = Option(index: wordIndex, value: Constants.blankString, line: lineNumber)
            }
            
            
            //Find previous selected word at this position to show the marked value on picker
            
            if let option = wikiArticle?.tempOption,/*checking for nil*/
                let userSelectedOption = wikiArticle?.userSelectedOptions,/*checking for nil*/
                let selectedOption = userSelectedOption.index(of: option),/*Previous selected option for this index*/
                let index = wikiArticle?.correctOptions.index(where: {$0.value == userSelectedOption[Int(selectedOption)].value})/*Finding the index of selected value in picker list*/ {
                picker?.setSelectedRows([Int(index)])
            }else{
                picker?.unselectAll()
            }
            
            
            picker?.show()
        }
        
    }
    
}

//MARK:- Picker delegate
extension GameViewController: CZPickerViewDataSource{
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return wikiArticle?.correctOptions.count ?? 0
    }
    
    func czpickerView(_ pickerView: CZPickerView!, attributedTitleForRow row: Int) -> NSAttributedString! {
        return NSAttributedString(string: wikiArticle?.correctOptions[row].value ?? "")
    }
}

extension GameViewController: CZPickerViewDelegate{
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        
        //Creating user selected option and put in text
        if let option = wikiArticle?.correctOptions[row], let lineNumber = wikiArticle?.tempOption?.line, let wordIndex = wikiArticle?.tempOption?.index{
            let selectedOption = Option(index: wordIndex, value: option.value, line: lineNumber)
            
            wikiArticle?.userSelected(option: selectedOption)
            DispatchQueue.main.async {[weak self] in
                if let cell = self?.gameTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? IntroParaTableViewCell{
                    //Configuring cell with updated Text
                    cell.configure(text: self?.wikiArticle?.attributedText)
                }
            }
            
        }
    }
    
    
}

//MARK:- Right Nav button action
extension GameViewController {
    
    override func rightButtonAction(sender: UIButton) {
        
        let endGameViewController = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: EndGameViewController.className()) as? EndGameViewController ?? EndGameViewController()
        endGameViewController.pointScored = wikiArticle?.findUserScore()
        endGameViewController.delegate = self
        self.navigationController?.pushViewController(endGameViewController, animated: true)
        
    }
    
}


//MARK:- RefreshTableContentDelegate
extension GameViewController: RefreshTableContentDelegate{
    //To refresh table with new article
    func refresh(article: WikiArticle?) {
        self.wikiArticle = article
        self.gameTableView.setContentOffset(.zero, animated: false)
        self.gameTableView.reloadData()
    }
    
}




