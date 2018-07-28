//
//  LandingViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 26/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import Lottie

enum ViewState {
    case normal, searching, error
}

class LandingViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var errorLBL: UILabel!
    let animationView: LOTAnimationView = LOTAnimationView(name: "animation-w400-h300.json")
    
    @IBOutlet weak var playBTN: UIButton!
    
    //Three states of views are maintained.
    var viewState: ViewState = .normal{
        
        didSet{
            setupView()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewState = .normal
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //To reconfigure the animation to button centre
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            self?.animationView.frame = (self?.playBTN.frame)!
            self?.animationView.center = (self?.playBTN.center)!
        }
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        
        viewState = .searching
        
        //Request for wiki Article
        ArticleParser.shared.requestWikiArticle { (article, success) in
            if success{
                
                //Present game controller
                DispatchQueue.main.async {[weak self] in
                    
                    let gameViewController = UIStoryboard.init(storyboard: .main).instantiateViewController(withIdentifier: GameViewController.className()) as? GameViewController ?? GameViewController()
                    gameViewController.wikiArticle = article
                    let navController = UINavigationController(rootViewController: gameViewController)
                    
                    self?.present(navController, animated: true, completion: nil)
                    self?.viewState = .normal
                    
                }
            } else {
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .error
                }
            }
        }
    }
    
    
    //Configurung view based on view state
    func setupView() {
        
        switch viewState {
        case .normal:
            animationView.removeFromSuperview()
            playBTN.isUserInteractionEnabled = true
            errorLBL.isHidden = true
            playBTN.setImage(#imageLiteral(resourceName: "sharp_play_arrow"), for: .normal)
            animationView.stop()
        case .error:
            animationView.removeFromSuperview()
            playBTN.isUserInteractionEnabled = true
            errorLBL.isHidden = false
            animationView.stop()
            playBTN.setImage(#imageLiteral(resourceName: "sharp_play_arrow"), for: .normal)
        case .searching:
            errorLBL.isHidden = true
            animationView.loopAnimation = true
            backgroundView.addSubview(animationView)
            animationView.contentMode = .scaleAspectFit
            animationView.play()
            playBTN.isUserInteractionEnabled = false
            playBTN.setImage(nil, for: .normal)
        }
        
    }
    

}
