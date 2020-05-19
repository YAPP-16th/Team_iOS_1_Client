//
//  SettingViewController.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingViewModel!

	@IBOutlet var settingTableView: UITableView!
	
	@IBOutlet var loginView: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		loginView.isUserInteractionEnabled = true
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
		loginView.addGestureRecognizer(tapRecognizer)
		
	}
	
	func loginTapped(sender: UIView) {
		print("login tapped!!!!!")
	}
	
	func bindViewModel() {
		
		settingTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)


		viewModel.outputs.settingMenu
			.bind(to: settingTableView.rx.items(cellIdentifier: "settingCell")) {
				(index: Int, element: String, cell: SettingListCell) in

				cell.settingListLabel?.text = element

		}.disposed(by: disposeBag)
		
		
		
		settingTableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.row == 0 {
					self?.viewModel.inputs.showAlarmDetailVC()
				} else if indexPath.row == 1 {
					self?.viewModel.inputs.showPlaceDetailVC()
				} else if indexPath.row == 2 {
					self?.viewModel.inputs.showOtherDetailVC()
				}
			})
			.disposed(by: disposeBag)
				
		
	}
}



extension SettingViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.borderWidth = 0.3
		view.layer.borderColor = UIColor.gray.cgColor
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingTableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingListCell: UITableViewCell {
	@IBOutlet var settingListLabel: UILabel!
}
