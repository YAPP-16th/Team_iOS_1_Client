//
//  TextFieldTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class TextFieldTableViewCell: UITableViewCell {
    
    @objc func didTapDatePickerDone() {
        if datePicker.date < Date() {
            datePicker.date = Date()
        }
        viewModel?.inputs.insertedDateRelay.accept(datePicker.date)
        textField.text = datePicker.date.endTime
        self.endEditing(true)
    }
    
    @objc func didTapDatePickerCancel() {
        textField.text = nil
        self.endEditing(true)
    }
    
    var viewModel: AddPlantViewModel?
    var disposeBag = DisposeBag()

    func configure(viewModel vm: AddPlantViewModel, text: String, placeholder: String, enabled: Bool, isDate : Bool = false) {
        print("in textField: \(text)")
        textField.text = text
        textField.placeholder = placeholder
        
        viewModel = vm
        guard viewModel != nil else { return }
        
        if isDate {
            textField.inputView = datePicker
            textField.inputAccessoryView = toolBar
        } else {
            textField.inputView = nil
            textField.inputAccessoryView = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    @IBOutlet var textField: UITextField!
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .init(identifier: "ko-KR")
        datePicker.datePickerMode = .date
//        viewModel?.insertedDateRelay
//            .compactMap { $0 }
//            .bind(to: datePicker.rx.date)
//            .disposed(by: disposeBag)
//
//        datePicker.rx.date
//            .map { $0.endTime }
//            .bind(to: textField.rx.text)
//            .disposed(by: <#T##DisposeBag#>)
//
        if let date = viewModel?.insertedDateRelay.value {
            datePicker.date = date
            textField.text = date.endTime
        }
        return datePicker
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(didTapDatePickerCancel))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(didTapDatePickerDone))
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }()
}
