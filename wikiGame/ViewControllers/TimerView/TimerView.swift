//
//  TimerView.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 04/08/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit

class TimerView: UIView {

    @IBOutlet weak var displayLBL: UILabel!
    static func getInstance() -> TimerView {
        
        let view = Bundle.main.loadNibNamed("TimerView", owner: self, options: nil)?.first as? TimerView
        
        
        
        
        return view ?? TimerView()
    }

}
