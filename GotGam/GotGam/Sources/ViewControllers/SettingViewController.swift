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
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		
	}
	
	func bindViewModel() {
		
		settingTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		print(viewModel.outputs.citiesOb)
		viewModel.outputs.citiesOb
			.bind(to: settingTableView.rx.items(cellIdentifier: "settingCell")) {
				(index: Int, element: String, cell: UITableViewCell) in
				
				cell.textLabel?.text = element
				
		}.disposed(by: disposeBag)
			
		settingTableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.row == 0 {
					self?.viewModel.inputs.showDetailVC()
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
}
