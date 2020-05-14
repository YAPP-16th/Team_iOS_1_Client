//
//  AddTagTableViewCell.swift
//  GotGam
//
//  Created by woong on 02/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class SetTagListTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()

    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var selectImageView: UIImageView!
    
    func configure(viewModel: SetTagViewModel, tag: Tag) {
        tagLabel.text = tag.name
        tagView.backgroundColor = tag.hex.hexToColor()

        
        viewModel.selectedTag
            .map { !($0 == tag) }
            .bind(to: selectImageView.rx.isHidden)
            .disposed(by: disposeBag)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
}
