//
//  IntroParaTableViewCell.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

class IntroParaTableViewCell: UITableViewCell {
    @IBOutlet weak var displayTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(wikiElement: WikiElements?, arr:Array<Range<String.Index>>?) {
        var text = wikiElement?.body
        if let rangeArr = arr{
            
            for range in rangeArr{
                
                text = text?.replacingCharacters(in: range, with: "__________")
                
            }
            
        }
        
        self.displayTextView.text = text
    }
    
}

