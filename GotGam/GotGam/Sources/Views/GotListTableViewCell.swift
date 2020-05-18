//
//  GotListTableViewCell.swift
//  GotGam
//
//  Created by woong on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GotListTableViewCell: UITableViewCell {
    
    var viewModel: GotListViewModel!
    let disposeBag = DisposeBag()
    var tagColor: UIColor?
    
    @IBAction func didTapFinish(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            titleLabel.textColor = .veryLightPink
            tagView.backgroundColor = .veryLightPink
            placeLabel.textColor = .veryLightPink
            dateLabel.textColor = .veryLightPink
            arriveMsgLabel.textColor = .veryLightPink
            gotImageButton.isEnabled = !sender.isSelected
            moreButton.isEnabled = !sender.isSelected
        } else {
            titleLabel.textColor = .brownishGrey
            tagView.backgroundColor = tagColor
            placeLabel.textColor = .brownGrey
            dateLabel.textColor = .brownishGrey
            arriveMsgLabel.textColor = .brownishGrey
            moreButton.setImage(UIImage(named: "icMore"), for: .normal)
            gotImageButton.isEnabled = !sender.isSelected
            moreButton.isEnabled = !sender.isSelected
        }
    }
    
    // MARK: - Intializing
    
    func configure(viewModel: GotListViewModel, _ got: Got) {
        
        tagColor = got.tag?.first?.hex.hexToColor()
            
        titleLabel.text = got.title
        tagView.backgroundColor = tagColor
        placeLabel.text = got.place
        placeLabel.numberOfLines = 0
        placeLabel.sizeToFit()
        dateLabel.text = got.insertedDate?.endTime
        //finishButton
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
    
    // MARK: - Views
    
    
    @IBOutlet var gotImageButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagView: UIView!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var arriveMsgLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    
}
