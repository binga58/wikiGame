//
//  UIViewControllerExtension.swift
//  Tillo
//
//  Created by Abhishek Sharma on 27/06/18.
//  Copyright © 2018 Finoit Technologies. All rights reserved.
//

import Foundation
import UIKit

let kMinButtonWidth : CGFloat = 30

//MARK:- ENUMS
enum BarButtonPosition
{
    case Left,Right
}

enum BarButtontype : Int
{
    case none = 1,done, back
    
    
    
    func typeData() -> AnyObject
    {
        switch self {
        case .done:
            return Constants.done as AnyObject
        case .back:
            return "Back" as AnyObject
        default:
            return "" as AnyObject
        }
    }
}


extension UIViewController
{
    //MARK:- navigation bar methods
    func setNavigationBarWithTitle(title:String?, LeftButtonType leftButtonType:BarButtontype, RightButtonType rightButtonType:BarButtontype)
    {
        setNavigationBarWithTitle(title: title, LeftButtonType: [leftButtonType], RightButtonType: [rightButtonType])
    }
    
    func setNavigationBarWithTitle(title:String?, LeftButtonType leftButtonType:[BarButtontype], RightButtonType rightButtonType:BarButtontype)
    {
        setNavigationBarWithTitle(title: title, LeftButtonType: leftButtonType, RightButtonType: [rightButtonType])
    }
    
    func setNavigationBarWithTitle(title:String?, LeftButtonType leftButtonType:BarButtontype, RightButtonType rightButtonType:[BarButtontype])
    {
        setNavigationBarWithTitle(title: title, LeftButtonType: [leftButtonType], RightButtonType: rightButtonType)
    }
    
    //MARK:- navigation bar method for multiple barbutton items
    func setNavigationBarWithTitle(title:String?, LeftButtonType leftButtonType:[BarButtontype], RightButtonType rightButtonType:[BarButtontype])
    {
        self.navigationItem.titleView = nil
        self.navigationItem.title = title
        setBarButtonAt(position: .Left, Type: leftButtonType)
        setBarButtonAt(position: .Right, Type: rightButtonType)
        configureNavigationBar()
    }
    
    func setNavigationBarWithTitle(titleView:UIView?, LeftButtonType leftButtonType:[BarButtontype], RightButtonType rightButtonType:[BarButtontype])
    {
        self.navigationItem.titleView = titleView
        setBarButtonAt(position: .Left, Type: leftButtonType)
        setBarButtonAt(position: .Right, Type: rightButtonType)
        configureNavigationBar()
    }
    
    func configureNavigationBar()  {
        //set color on image on navigation bar
        if var navigationBarFrame = self.navigationController?.navigationBar.frame
        {
            navigationBarFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: navigationBarFrame.width, height: navigationBarFrame.height + 20))
        }
        //set title color on navigatoin bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.theme ,NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)]
    }
    
    
    //MARK:- navigation bar button setup method
    private func setBarButtonAt(position:BarButtonPosition, Type typeArray:[BarButtontype])
    {
        var barButtonArray : [UIBarButtonItem] = []
        
        for type in typeArray {
            var barButton : UIBarButtonItem?
            
            switch type
            {
            case .none:
                barButton = nil
            default:
                //for text
                if let string = type.typeData() as? String{
                    barButton = UIBarButtonItem(customView: getButtonWithText(text: string , type: type , position:  position ))
                }
                
                //for image
                if let image = type.typeData() as? UIImage{
                    barButton = UIBarButtonItem(customView: getButtonWithImage(image: image , type: type , position:  position))
                    barButton?.tintColor = UIColor.theme
                }
                
                //for text and touple
                if let imageTouple = type.typeData() as? (first : String, second : UIImage){
                    let toupleButton = UIButton(type:.system)
                    toupleButton.setAttributedTitle(NSAttributedString(string:" \(imageTouple.first)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.theme , NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)]), for: .normal)
                    self.setActionToButtonAccordingToPosition(position: position, type: type, button: toupleButton)
                    toupleButton.setImage(imageTouple.second, for: .normal)
                    toupleButton.tintColor = UIColor.theme
                    toupleButton.sizeToFit()
                    barButton = UIBarButtonItem(customView: toupleButton )
                }
                
                barButton?.tag = type.rawValue
            }
            
            
            if let button = barButton{
                barButtonArray.append(button)
            }
        }
        
        switch position
        {
        case .Left:
            self.navigationItem.setLeftBarButtonItems(barButtonArray, animated: false)
        case .Right:
            self.navigationItem.setRightBarButtonItems(barButtonArray, animated: false)
        }
    }
    
    
    //MARK:- navigation bar button fetch methods (according to string || according to image)
    private func getButtonWithImage(image: UIImage?, type: BarButtontype ,position: BarButtonPosition) -> UIButton
    {
        let button = UIButton(type:.custom)
        button.setImage(image, for: .normal)
        
        //setting color of button according to theme
        //        button.tintColor = UIColor.white
        self.setActionToButtonAccordingToPosition(position: position, type: type, button: button)
        button.tag = type.rawValue
        return button
    }
    
    private func getButtonWithText(text: String?, type: BarButtontype, position:  BarButtonPosition) -> UIButton
    {
        let button = UIButton(type:.system)
        button.setAttributedTitle(NSAttributedString(string: (text ?? ""), attributes: [NSAttributedStringKey.foregroundColor : UIColor.theme , NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)]), for: .normal)
        self.setActionToButtonAccordingToPosition(position: position, type: type, button: button)
        return button
    }
    
    
    
    //MARK:- action according to position
    private func setActionToButtonAccordingToPosition(position: BarButtonPosition , type: BarButtontype , button : UIButton)
    {
        button.sizeToFit()
        button.clipsToBounds = true
        button.tag = type.rawValue
        button.contentHorizontalAlignment =  position == .Left ? .left : .right
        
        
        //adjust min frame
        let width = button.frame.size.width > kMinButtonWidth ? button.frame.size.width : kMinButtonWidth
        let height = button.frame.size.height > kMinButtonWidth ? button.frame.size.height : kMinButtonWidth
        button.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
        
        //set position
        switch position
        {
        case .Left:
            button.addTarget(self, action: #selector(self.leftButtonAction(sender:)), for: .touchUpInside)
        case .Right:
            button.addTarget(self, action: #selector(self.rightButtonAction(sender:)), for: .touchUpInside)
        }
        
        
    }
    
    //MARK:- navigation bar button actions
    @IBAction func leftButtonAction(sender: UIButton)
    {
       
        
    }
    
    @IBAction func rightButtonAction(sender:UIButton)
    {
        
    }
}

//MARK:- class methods
extension UIViewController
{
    class func getTopMostViewController() -> UIViewController? {
        
        if let rootViewCont =  UIApplication.shared.keyWindow?.rootViewController{
            return self.getTopPresentedViewController(viewControllerObj: rootViewCont)
        }
        return nil
    }
    
    class func getTopPresentedViewController(viewControllerObj:UIViewController) -> UIViewController {
        
        if let presentedViewController = viewControllerObj.presentedViewController {
            return self.getTopPresentedViewController(viewControllerObj: presentedViewController)
        }else{
            return viewControllerObj
        }
    }
}

