//
//  ToggleableTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class ToggleableTableViewCell: UITableViewCell {

    var viewModel: AddPlantViewModel?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var enableSwitch: UISwitch!
    
    var disposedBag = DisposeBag()
    
    func configure(viewModel vm: AddPlantViewModel, title: String) {
        viewModel = vm
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        
    }
}
