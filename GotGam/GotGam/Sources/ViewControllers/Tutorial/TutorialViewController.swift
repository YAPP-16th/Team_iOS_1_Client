//
//  TutorialViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController{
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    var currentIndex: Int!
    var message: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.layer.cornerRadius = 9
        skipButton.layer.masksToBounds = true
        skipButton.layer.borderWidth = 1.0
        skipButton.layer.borderColor = UIColor.saffron.cgColor
        
        pageControl.currentPage = currentIndex
        self.messageLabel.text = message
    }
    
    @IBAction func skipAction(sender: UIButton){
        //Todo: Skip tutorial and show login VC
    }
}
