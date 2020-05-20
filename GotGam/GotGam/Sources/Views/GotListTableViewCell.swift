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
    var moreAction: (() -> Void)?
    var got: Got? {
        didSet {
            guard let got = got else { return }
            tagColor = self.got?.tag?.first?.hex.hexToColor()
                
            titleLabel.text = got.title
            tagView.backgroundColor = tagColor
            placeLabel.text = got.place
            dateLabel.text = got.insertedDate?.endTime
            restoreView.restoreAction = { [weak self] in
                self?.isChecked = false
            }
        }
    }
    
    var isChecked: Bool = false {
        didSet {
            guard var got = got else { return }
            got.isDone = isChecked
            viewModel.inputs.updateFinish(of: got)
            
            if isChecked {
                finishButton.isSelected = true
                titleLabel.textColor = .veryLightPink
                tagView.backgroundColor = .veryLightPink
                placeLabel.textColor = .veryLightPink
                dateLabel.textColor = .veryLightPink
                arriveMsgLabel.textColor = .veryLightPink
                gotImageButton.isEnabled = false
                moreButton.isEnabled = false
                
                
                UIView.animate(withDuration: 1, delay: 0.5, animations: {
                    self.restoreView.alpha = 1
                })
            } else {
                finishButton.isSelected = false
                titleLabel.textColor = .brownishGrey
                tagView.backgroundColor = tagColor
                placeLabel.textColor = .brownGrey
                dateLabel.textColor = .brownishGrey
                arriveMsgLabel.textColor = .brownishGrey
                moreButton.setImage(UIImage(named: "icMore"), for: .normal)
                gotImageButton.isEnabled = true
                moreButton.isEnabled = true
                restoreView.alpha = 0
            }
        }
    }
    
    @IBAction func didTapMoreButton(_ sender: Any) {
        self.moreAction?()
    }
    
    @IBAction func didTapFinish(_ sender: UIButton) {
        isChecked.toggle()
    }
    
    // MARK: - Intializing
    
    func configure(viewModel: GotListViewModel, _ got: Got) {
        self.viewModel = viewModel
        self.got = got
        isChecked = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        restoreView.alpha = 0
        DispatchQueue.main.async { self.restoreView.contentView.clipsToBounds = false
        }
        
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
    @IBOutlet var restoreView: MapRestoreView!
    
}
