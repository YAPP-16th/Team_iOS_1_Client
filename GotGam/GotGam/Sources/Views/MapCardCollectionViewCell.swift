//
//  MapCardCollectionViewCell.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/23.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MapCardCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var disposeBag = DisposeBag()
    var isDoneFlag = false{
        didSet{
            self.doneButton.backgroundColor = isDoneFlag ? .white : .orange
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale.init(identifier: "Ko_kr")
        return df
    }()
    
    var got: Got? {
        didSet{
            guard let got = got else { return }
            titleLabel.text = got.title
            addressLabel.text = got.address
            dueDateLabel.text = self.dateFormatter.string(from: got.dueDate)
            self.isDoneFlag = got.isFinished
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.applySketchShadow(color: .black, alpha: 0.05, x: 0, y: 2, blur: 10, spread: 0)
        self.contentView.layer.cornerRadius = 24
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
        
        tagView.layer.cornerRadius = 7
        tagView.layer.masksToBounds = true
        
        self.doneButton.layer.cornerRadius = 17
        self.doneButton.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
