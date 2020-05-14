//
//  InputTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class InputTagTableViewCell: UITableViewCell {
    
    var viewModel: AddPlantViewModel!
    var disposeBag = DisposeBag()

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagColorView: UIView!
    @IBOutlet var tagLabel: UILabel!
    
    
    func configure(viewModel: AddPlantViewModel, title: String) {
        titleLabel.text = title
        self.viewModel = viewModel
        
        viewModel.tag
            .compactMap{ $0?.hex.hexToColor() }
            .bind(to: tagColorView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagColorView.layer.cornerRadius = tagColorView.bounds.height/2
    }

}
