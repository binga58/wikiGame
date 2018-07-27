//
//  LandingViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 26/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import Lottie

enum LandingViewState {
    case normal, searching, error
}

class LandingViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var errorLBL: UILabel!
    let animationView: LOTAnimationView = LOTAnimationView(name: "animation-w400-h300.json")
    
    @IBOutlet weak var playBTN: UIButton!
    var viewState: LandingViewState = .normal{
        
        didSet{
            setupView()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            self?.animationView.frame = (self?.playBTN.frame)!
            self?.animationView.center = (self?.playBTN.center)!
        }
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        viewState = .searching
        ArticleParser.shared.requestWikiArticle { (article, success) in
            if success{
                article?.createMissingWords()
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .normal
                }
            } else {
                DispatchQueue.main.async {[weak self] in
                    self?.viewState = .error
                }
            }
        }
    }
    
    
    
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
