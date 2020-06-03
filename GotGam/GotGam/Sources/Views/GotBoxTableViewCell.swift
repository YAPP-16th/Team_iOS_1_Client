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
    var got: Got!
    var moreAction: (() -> Void)?
    
    // MARK: - Methods
    
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        self.moreAction?()
    }
    
    // MARK: - Initializing
    
    func configure(viewModel: GotBoxViewModel, got: Got) {
        self.viewModel = viewModel
        self.got = got
        
        tagView.backgroundColor = got.tag?.hex.hexToColor()
        titleLabel.text = got.title
        placeLabel.text = got.place
        
        messageLabel.text = got.arriveMsg == "" ? got.deparetureMsg : got.arriveMsg
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.layer.cornerRadius = tagView.bounds.height/2
        dateLabel.padding = .init(top: 1, left: 8, bottom: 1, right: 8)
        dateLabel.layer.cornerRadius = 10
        dateLabel.layer.borderWidth = 1
        dateLabel.layer.borderColor = UIColor.saffron.cgColor
    }

    @IBOutlet var tagView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var dateLabel: PaddingLabel!
    @IBOutlet var messageLabel: UILabel!
}
