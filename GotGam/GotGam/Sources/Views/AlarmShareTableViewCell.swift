//
//  AlarmShareTableViewCell.swift
//  GotGam
//
//  Created by woong on 21/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AlarmShareTableViewCell: UITableViewCell {
    
    var viewModel: AlarmViewModel!
    
    func configure(viewModel: AlarmViewModel, alarm: ManagedAlarm) {
        self.viewModel = viewModel
        
        
        //viewModel.storage.fetchTag(hex: alarm.tag)
        guard let tagHex = alarm.tag,
            let tag = DBManager.share.fetchTag(hex: tagHex)?.toTag() else {
                return
        }
        
        
        let tagName = tag.name
        let userName = "슬기로운곳감생활"
        shareTagLabel.text = "\(userName)님이 '\(tagName)'태그를 공유했습니다."
        
        let attributedString = NSMutableAttributedString(string: "\(userName)님이 ‘\(tagName)’태그를 공유했습니다.", attributes: [
          .font: UIFont(name: "SpoqaHanSans-Regular", size: 14.0)!,
          .foregroundColor: UIColor.black
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "SpoqaHanSans-Bold", size: 14.0)!, range: NSRange(location: userName.count + 4, length: tagName.count + 2))
        
        backgroundColor = alarm.isChecked ? .white : .offWhite
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        rejectButton.layer.cornerRadius = rejectButton.bounds.height/2
        acceptButton.layer.cornerRadius = rejectButton.bounds.height/2
    }

    @IBOutlet var shareTagLabel: UILabel!
    @IBOutlet var agoTimeLabel: UILabel!
    @IBOutlet var rejectButton: UIButton!
    @IBOutlet var acceptButton: UIButton!
}
