//
//  SettingOtherViewController.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingOtherViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingOtherViewModel!
	
	@IBOutlet var settingOtherTableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
	}
	
	func bindViewModel() {
		
		settingOtherTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		
		viewModel.outputs.settingOtherMenu
			.bind(to: settingOtherTableView.rx.items(cellIdentifier: "settingOtherCell")) {
				(index: Int, element: String, cell: SettingOtherCell) in
				
				cell.settingOtherLabel?.text = element
				
				
		}.disposed(by: disposeBag)
		
	}
	
}

extension SettingOtherViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingOtherTableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingOtherCell: UITableViewCell {
	
	@IBOutlet var settingOtherLabel: UILabel!
}
