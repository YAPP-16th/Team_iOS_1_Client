//
//  SettingPlaceViewController.swift
//  GotGam
//
//  Created by 김삼복 on 19/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingPlaceViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingPlaceViewModel!
	
	@IBOutlet var settingPlaceTableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
	}
	
	func bindViewModel() {
			
			settingPlaceTableView.rx.setDelegate(self)
				.disposed(by: disposeBag)

		}
		
	}

extension SettingPlaceViewController: UITableViewDelegate {
		
		func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
			let view = UIView()
			view.backgroundColor = .clear
			return view
		}
}
