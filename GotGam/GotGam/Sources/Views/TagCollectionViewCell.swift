//
//  TagCollectionViewCell.swift
//  GotGam
//
//  Created by woong on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class TagCollectionViewCell: UICollectionViewCell {
    
    func configure(_ tag: Tag) {
        tagView.backgroundColor = tag.hex.hexToColor()
        tagLabel.text = tag.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagView.layer.cornerRadius = tagView.bounds.height/2
        backgroundColor = .white
        shadow(radius: 3, color: .black, offset: .init(width: 0, height: 3), opacity: 0.2)
    }
    
    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!
}
