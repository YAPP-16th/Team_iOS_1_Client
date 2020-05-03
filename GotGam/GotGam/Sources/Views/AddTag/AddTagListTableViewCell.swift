//
//  AddTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 02/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddTagListTableViewCell: UITableViewCell {

    

    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var selectImageView: UIImageView!
    
    func configure(tag: String, selected: Bool) {
        tagLabel.text = tag
        tagView.backgroundColor = .orange
        //selectImageView.ishidden = !selected
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
