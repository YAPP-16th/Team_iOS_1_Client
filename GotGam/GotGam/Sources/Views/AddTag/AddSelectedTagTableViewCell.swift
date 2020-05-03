//
//  AddSelectedTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddSelectedTagTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagColorView: UIView!
    @IBOutlet var tagLabel: UILabel!
    
    func configure(title: String, tag: String?) {
        titleLabel.text = title
        if let tag = tag {
            //tagColorView.backgroundColor = tag.color
            tagLabel.text = tag
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagColorView.layer.cornerRadius = tagColorView.bounds.height/2
    }
}
