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
	
	var placeList: [String] = ["1", "1", "1"] {
		didSet{
			DispatchQueue.main.async {
				self.settingPlaceTableView.reloadData()
			}
		}
		
	}
	
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

extension SettingPlaceViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return self.placeList.count
		} else {
			return 2
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 1 {
//			let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
			let cell = tableView.dequeueReusableCell(withIdentifier: "placeAddCell", for: indexPath) as! PlaceAddCell
			cell.placeAddButton.layer.cornerRadius = cell.placeAddButton.bounds.height/2
			cell.placeAddButton.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
			
			return cell
		} else {
			fatalError()
		}
	}
	
}

class PlaceAddCell: UITableViewCell {
	
	@IBOutlet var placeAddButton: UIButton!
	
}
