//
//  SettingAlarmViewController.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingAlarmViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingAlarmViewModel!
	
	@IBOutlet var settingAlarmTableView: UITableView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never

	}
	
	func bindViewModel() {
		
		settingAlarmTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		
		viewModel.outputs.settingAlarmMenu
			.bind(to: settingAlarmTableView.rx.items(cellIdentifier: "settingToggleCell")) {
				(index: Int, element: String, cell: SettingAlarmCell) in
				
				cell.settingAlarmListLabel?.text = element
				cell.alarmSwitch.onTintColor = .saffron
				
		}.disposed(by: disposeBag)
		
	}
	
//	func settingToggle() {
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
//		print("settingToggle")
//	}
}

extension SettingAlarmViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingAlarmTableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row == 0 {
			if #available(iOS 10.0, *) {
				let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)! as URL
				UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
			}
		} else {
			fatalError()
		}
	}
	
}

class SettingAlarmCell: UITableViewCell {
	
	@IBOutlet var settingAlarmListLabel: UILabel!
	@IBOutlet var alarmSwitch: UISwitch!
}
