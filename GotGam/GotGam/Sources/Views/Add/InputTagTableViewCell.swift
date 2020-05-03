//
//  InputTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class InputTagTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagColorView: UIView!
    @IBOutlet var tagLabel: UILabel!
    
    
    func configure(title: String, tag: String?) {
        titleLabel.text = title
        if let tag = tag {
            tagLabel.text = tag
            // tagColorView.backgroundColor = tag.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagColorView.layer.cornerRadius = tagColorView.bounds.height/2
    }

}
