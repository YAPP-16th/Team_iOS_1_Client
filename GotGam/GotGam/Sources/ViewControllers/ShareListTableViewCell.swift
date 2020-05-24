//
//  ShareListTableViewCell.swift
//  GotGam
//
//  Created by woong on 24/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class ShareListTableViewCell: UITableViewCell {
    
    var viewModel: ShareListViewModel!
    var shareAction: (() -> ())?
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        shareAction?()
    }
    
    func configure(viewModel: ShareListViewModel, tag: Tag) {
        self.viewModel = viewModel
        
        tagView.backgroundColor = tag.hex.hexToColor()
        tagLabel.text = tag.name
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
    
    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!
}
