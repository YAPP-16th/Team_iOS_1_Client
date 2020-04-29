//
//  AddItemTableViewCell.swift
//  GotGam
//
//  Created by woong on 28/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    
    var item: InputItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title
            detailTextField.placeholder = item.placeholder
            setup(item)
            
        }
    }
    
    func setup(_ item: InputItem) {
        
        switch item {
        case .tag:
            tagView.isHidden = false
            detailTextField.text = item.placeholder
        case .endDate:
            datePicker?.addTarget(self, action: #selector(onChangeEndDate), for: .valueChanged)
            detailTextField.inputView = datePicker
            detailTextField.inputAccessoryView = toolBar
            detailTextField.isEnabled = true
        case .alramMsg:
            detailTextField.isEnabled = true
            detailTextField.tintColor = .orange
        }
    }
    
    @objc func onChangeEndDate() {
        detailTextField.text = datePicker?.date.endDate
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if selected {
//            placeholderLabel.isHidden = true
//        } else { // if item 이 안 정해졌으면,
//            placeholderLabel.isHidden = false
//        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagView.layer.cornerRadius = tagView.bounds.height / 2
        print(accessoryView?.frame)
    }
    
    // MARK: - Views
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailView: UIView!
    @IBOutlet var detailTextField: UITextField!
    @IBOutlet var tagView: UIView!
    var datePicker: UIDatePicker?
    var toolBar: UIToolbar?

}

extension Date {
    var endDate: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd.E"
        return df.string(from: self)
    }
}
