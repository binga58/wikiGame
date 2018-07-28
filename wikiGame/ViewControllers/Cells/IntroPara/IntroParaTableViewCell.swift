//
//  IntroParaTableViewCell.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

protocol TextfieldURLInteractionDelegate: NSObjectProtocol {
    func interacted(with url: URL, range: NSRange)
}

class IntroParaTableViewCell: UITableViewCell {
    @IBOutlet weak var displayTextView: UITextView!
    weak var delegate: TextfieldURLInteractionDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        displayTextView.delegate = self
        displayTextView.dataDetectorTypes = .link
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(text: NSAttributedString?) {
        displayTextView.delegate = self
        self.displayTextView.attributedText = text
    }
    
}

extension IntroParaTableViewCell: UITextViewDelegate{
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        delegate?.interacted(with: URL, range: characterRange)
        return false
    }
    
}

