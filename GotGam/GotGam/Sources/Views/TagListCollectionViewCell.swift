//
//  TagListCollectionViewCell.swift
//  GotGam
//
//  Created by woong on 24/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TagListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadow(radius: 3, color: .black, offset: .init(width: 0, height: 3), opacity: 0.2)
    }

}
