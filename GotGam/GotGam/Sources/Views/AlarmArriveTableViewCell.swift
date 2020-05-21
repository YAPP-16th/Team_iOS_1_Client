//
//  AlarmArriveTableViewCell.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class AlarmArriveTableViewCell: UITableViewCell {
    
    var viewModel: AlarmViewModel!
    var disposeBag = DisposeBag()
    
    func configure(viewModel: AlarmViewModel, alarm: Alarm) {
        self.viewModel = viewModel
        
        guard let got = alarm.got else { return }
        
        titleLabel.text = got.title
        memoLabel.text = got.arriveMsg
        tagView.backgroundColor = got.tag?.first?.hex.hexToColor()
        
        if let date = got.insertedDate {
            dateLabel.text = date.endTime
            // 현재시간 기준 계산
        }
        
        if let createdDate = alarm.createdDate {
            let agoDate = Calendar.current.dateComponents([.hour, .minute], from: createdDate, to: Date()).minute
            agoTimeLabel.text = "\(agoDate ?? 0)분 전"
            //agoTimeLabel.text = agoDate?.format("mm분 전")
        }
        
        self.backgroundColor = alarm.isChecked ? .white : .offWhite
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tagView.layer.cornerRadius = tagView.bounds.height/2
    }
    
    @IBOutlet var tagView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var memoLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dateCommentLabel: UILabel!
    @IBOutlet var agoTimeLabel: UILabel!
    
}
