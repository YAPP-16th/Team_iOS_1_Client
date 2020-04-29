//
//  MapCardCollectionViewCell.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/23.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class MapCardCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    
    var cancelAction: (() -> Void)? = { }
    var doneAction: (() -> Void)? = { }
    @IBAction func cancelButtonTapped(_ sender: UIButton){
        cancelAction?()
    }
    @IBAction func doneButtonTapped(_ sender: UIButton){
        doneAction?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layer.cornerRadius = 24
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 24.0
        self.layer.shadowOpacity = 0.25
        
        tagView.layer.cornerRadius = 7
        tagView.layer.masksToBounds = true
        
        self.doneButton.layer.cornerRadius = 17
        self.doneButton.layer.masksToBounds = true
    }
}
