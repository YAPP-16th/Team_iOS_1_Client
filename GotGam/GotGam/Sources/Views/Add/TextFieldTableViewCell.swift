//
//  TextFieldTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet var textField: UITextField!
    
    func configure(text: String, placeholder: String, enabled: Bool) {
        textField.text = text
        textField.placeholder = placeholder
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
