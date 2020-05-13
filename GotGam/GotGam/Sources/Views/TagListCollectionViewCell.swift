//
//  TagListCollectionViewCell.swift
//  GotGam
//
//  Created by woong on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TagListCollectionViewCell: UICollectionViewCell {
    
    func configure(_ tag: Tag) {
        tagView.backgroundColor = tag.hex.hexToColor()
        tagNameLabel.text = tag.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
    
    @IBOutlet var tagView: UIView!
    @IBOutlet var tagNameLabel: UILabel!
}
