//
//  SettingLoginViewController.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class SettingLoginViewController: BaseViewController, ViewModelBindableType {

	var viewModel: SettingLoginViewModel!
	
	@IBOutlet var settingLoginTableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
	}
	
	func bindViewModel() {
		settingLoginTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		
		viewModel.outputs.settingLoginMenu
			.bind(to: settingLoginTableView.rx.items(cellIdentifier: "settingLoginCell")) {
				(index: Int, element: String, cell: SettingLoginCell) in
				cell.settingLoginLabel?.text = element
		}.disposed(by: disposeBag)

	}
		
}

extension SettingLoginViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.borderWidth = 0.3
		view.layer.borderColor = UIColor.lightGray.cgColor
		return view
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingLoginTableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingLoginCell: UITableViewCell {
	@IBOutlet var settingLoginLabel: UILabel!
	
}
