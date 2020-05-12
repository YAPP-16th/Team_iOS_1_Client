//
//  SettingAlarmViewController.swift
//  GotGam
//
//  Created by 김삼복 on 12/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingAlarmViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingAlarmViewModel!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
	}
	
	func bindViewModel() {
		
		
	}
	
	func settingToggle() {
//		guard let cell = table.dequeueReusableCell(withIdentifier: "settingToggleCell", for: indexPath) as? ToggleableTableViewCell else { return UITableViewCell()
//
//		cell.configure(viewModel: viewModel, title: title, enabled: enabled)
//
//		if indexPath.section == 1 {
//			cell.enableSwitch.rx
//				.isOn.changed
//				.debounce(.milliseconds(800), scheduler: MainScheduler.instance)
//				.bind(to: viewModel.isOnDate)
//				.disposed(by: cell.disposedBag)
//	}
		print("settingToggle")
	}
}

extension SettingAlarmViewController: UITableViewDelegate {
	
	
}
