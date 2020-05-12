//
//  MapTagCell.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/23.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class MapTagCell: UICollectionViewCell{
    @IBOutlet weak var tagIndicator: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var mapTag: Tag!{
        didSet{
            self.tagIndicator.backgroundColor = TagColor.init(rawValue: mapTag.color)?.color
            tagLabel.text = mapTag.name
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.2
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = false
        
        self.contentView.layer.cornerRadius = self.frame.height / 2
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
        self.tagIndicator.layer.cornerRadius = 7
        self.tagIndicator.layer.masksToBounds = true
    }
}
