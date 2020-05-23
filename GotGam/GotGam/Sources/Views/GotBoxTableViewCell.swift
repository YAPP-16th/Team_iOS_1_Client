//
//  GotBoxTableViewCell.swift
//  GotGam
//
//  Created by woong on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class GotBoxTableViewCell: UITableViewCell {
    
    var viewModel: GotBoxViewModel!
    
    func configure(viewModel: GotBoxViewModel, got: Got) {
        self.viewModel = viewModel
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
