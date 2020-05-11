//
//  CreateTextFieldTableViewCell.swift
//  GotGam
//
//  Created by woong on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateTextFieldTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    var viewModel: CreateTagViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        nameTextField.text = viewModel.inputs.tagName.value
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.tagName)
            .disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.tintColor = .orange
    }

    @IBOutlet var nameTextField: UITextField!
}
