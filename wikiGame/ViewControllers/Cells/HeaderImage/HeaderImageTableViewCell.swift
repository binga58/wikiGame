//
//  HeaderImageTableViewCell.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 22/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class HeaderImageTableViewCell: UITableViewCell {

    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var displayLBL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String?, imageURL: URL?) {
        self.displayLBL.text = title
        if let url = imageURL{
            displayImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "wikiLogo"), options: nil, progressBlock: nil) { (image, error, _, url) in
                
            }
        } else {
            
            displayImageView.image = #imageLiteral(resourceName: "wikiLogo")
        }
        
    }
    
}
