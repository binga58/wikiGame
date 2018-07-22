//
//  ParagraphTableViewCell.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

class ParagraphTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLBL: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(wikiElement: WikiElements?) {
        self.headerLBL.text = wikiElement?.title
        self.bodyTextView.text = wikiElement?.body
    }
    
}
