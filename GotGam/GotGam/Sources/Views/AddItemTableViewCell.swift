//
//  AddItemTableViewCell.swift
//  GotGam
//
//  Created by woong on 28/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailView: UIView!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var tagView: UIView!
    
    var item: InputItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title
            placeholderLabel.text = item.placeholder
            if item == .tag {
                tagView.isHidden = false
                placeholderLabel.textColor = .darkText
            }
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if selected {
//            placeholderLabel.isHidden = true
//        } else { // if item 이 안 정해졌으면,
//            placeholderLabel.isHidden = false
//        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagView.layer.cornerRadius = tagView.bounds.height / 2
    }

}
