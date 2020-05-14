//
//  GotListTableViewCell.swift
//  GotGam
//
//  Created by woong on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class GotListTableViewCell: UITableViewCell {
    
    
    func configure(_ got: Got) {
        titleLabel.text = got.title
        tagView.backgroundColor = got.tag?.first?.hex.hexToColor()
        placeLabel.text = got.place
        dateLabel.text = got.insertedDate?.endTime
        //finishButton
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
    
    @IBOutlet var gotImageView: UIImageView!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagView: UIView!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
}
