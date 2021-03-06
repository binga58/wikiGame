//
//  EndGameViewController.swift
//  wikiGame
//
//  Created by Abhishek Sharma on 27/07/18.
//  Copyright © 2018 Abhishek Sharma. All rights reserved.
//

import UIKit
import Lottie

protocol RefreshTableContentDelegate: class {
    func refresh(article: WikiArticle?, gameState: GameControllerState, gameDifficulty: GameDifficulty)
}

class EndGameViewController: UIViewController {
    
    @IBOutlet weak var difficultySwitch: UISwitch!
    var pointScored: Int?
    var wikiArticle: WikiArticle?
    //View states
    var viewState: ViewState = .normal{
        
        didSet{
            setViewState()
        }
        
    }
    weak var delegate: RefreshTableContentDelegate?
    let animationView: LOTAnimationView = LOTAnimationView(name: "animation-w400-h300.json")
    
    @IBOutlet weak var resultBTN: UIButton!
    @IBOutlet weak var pointsLBL: UILabel!
    @IBOutlet weak var refreshBTN: UIButton!
    @IBOutlet weak var errorLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewState = .normal
        
        resultBTN.isHidden = pointScored == 10 ? true : false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //To reconfigure the animation to button centre
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            self?.animationView.frame = (self?.refreshBTN.frame)!
            self?.animationView.center = (self?.refreshBTN.center)!
        }
    }
    
    func setupView() {
        self.navigationController?.navigationBar.isHidden = true
        pointsLBL.text = "You scored \(pointScored ?? 0) points"
        
    }
    
    func setViewState() {
        
        switch viewState {
        case .normal:
            animationView.removeFromSuperview()
            refreshBTN.isUserInteractionEnabled = true
            errorLBL.isHidden = true
            refreshBTN.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
            animationView.stop()
        case .error:
            animationView.removeFromSuperview()
            refreshBTN.isUserInteractionEnabled = true
            errorLBL.isHidden = false
            animationView.stop()
            refreshBTN.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        case .searching:
            errorLBL.isHidden = true
            animationView.loopAnimation = true
            view.addSubview(animationView)
            animationView.contentMode = .scaleAspectFit
            animationView.play()
            refreshBTN.isUserInteractionEnabled = false
            refreshBTN.setImage(nil, for: .normal)
        }
        
    }
    
    
    @IBAction func replayAction(_ sender: UIButton) {
        
        viewState = .searching
        
        ArticleParser.shared.requestWikiArticle {[weak self] (article, success) in
            if success {
                
                DispatchQueue.main.async {
                    let gameDifficulty: GameDifficulty = (self?.difficultySwitch.isOn ?? false) ? .hard : .easy
                    self?.delegate?.refresh(article: article, gameState: .game, gameDifficulty: gameDifficulty)
                    self?.navigationController?.popViewController(animated: true)
                    self?.viewState = .normal
                }
                
            }else {
                DispatchQueue.main.async {
                    self?.viewState = .error
                }
            }
        }
        
    }
    
    
    @IBAction func resultBTNAction(_ sender: Any) {
        
        let gameViewController = UIStoryboard.init(storyboard: .main).instantiateViewController(withIdentifier: GameViewController.className()) as? GameViewController ?? GameViewController()
        gameViewController.wikiArticle = wikiArticle
        gameViewController.gameControllerState = .result
        
        self.navigationController?.pushViewController(gameViewController, animated: true)
        
    }
    
}


