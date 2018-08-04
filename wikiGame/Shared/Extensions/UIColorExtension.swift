//
//  UIColorExtension.swift
//  Tillo
//
//  Created by Abhishek Sharma on 26/06/18.
//  Copyright © 2018 Finoit Technologies. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    
    static func getColorFromHexValue(hexValue:UInt64,Alpha alpha:CGFloat)-> UIColor{
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hexValue & 0xFF))/255.0, alpha: alpha)
    }
    
    static let theme:UIColor = {
        return UIColor.getColorFromHexValue(hexValue: 0x47A8EF, Alpha: 1.0)
    }()
    
    static let correct:UIColor = {
        return UIColor.getColorFromHexValue(hexValue: 0x428C2A, Alpha: 1.0)
    }()
    
    static let wrong:UIColor = {
        UIColor.red
    }()
    
}
