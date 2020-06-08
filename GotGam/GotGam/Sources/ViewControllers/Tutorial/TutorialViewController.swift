//
//  TutorialViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController{
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var currentIndex: Int!
    var message: String!
    
    var delegate: TutorialDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.text = message
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.indexChanged(currentIndex: currentIndex)
    }
    @IBAction func skipAction(sender: UIButton){
        //Todo: Skip tutorial and show login VC
    }
}
