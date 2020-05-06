//
//  AddTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 02/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class AddTagListTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()

    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var selectImageView: UIImageView!
    
    func configure(viewModel: AddTagViewModel, tag: String, selected: Bool) {
        tagLabel.text = tag
        tagView.backgroundColor = tag.hexToColor()

        
        viewModel.selectedTag
            .map { !($0 == tag) }
            .bind(to: selectImageView.rx.isHidden)
            .disposed(by: disposeBag)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
