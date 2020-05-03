//
//  ToggleableTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class ToggleableTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var enableSwitch: UISwitch!
    
    func configure(title: String, enabled: Bool) {
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        
    }
}
