//
//  ToggleableTableViewCell.swift
//  GotGam
//
//  Created by woong on 03/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class ToggleableTableViewCell: UITableViewCell {

    var viewModel: AddPlantViewModel?
	var viewModelSetting: SettingAlarmViewModel?
	
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var enableSwitch: UISwitch!
    
    var disposedBag = DisposeBag()
    
    func configure(viewModel vm: AddPlantViewModel, title: String, enabled: Bool) {
        viewModel = vm
        titleLabel.text = title
        
        guard let viewModel = viewModel else { return }
        print(enableSwitch.tag)
        if enableSwitch.tag == 1 {
            enableSwitch.rx.isOn.bind(to: viewModel.isOnDate).disposed(by: disposedBag)
        }
    }
	
	func configureSetting(viewModelSetting vm: SettingAlarmViewModel, title: String, enabled: Bool) {
        viewModelSetting = vm
        titleLabel.text = title
        
        guard let viewModel = viewModelSetting else { return }
        print(enableSwitch.tag)
        if enableSwitch.tag == 1 {
            enableSwitch.rx.isOn.bind(to: viewModel.isOnAlarm).disposed(by: disposedBag)
        }
    }
    
    override func awakeFromNib() {
        
    }
}
