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
	
	// MARK: - Properties
	
    var viewModel: SettingPlaceViewModel!
	
	@IBOutlet var settingPlaceTableView: UITableView!
	
	var placeList: [Frequent] = [] {
		didSet{
			DispatchQueue.main.async {
				self.settingPlaceTableView.reloadData()
			}
		}
		
	}
	
	// MARK: - View Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.inputs.readFrequents()
	}
	
	func bindViewModel() {
		settingPlaceTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		settingPlaceTableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.section == 0 {
					self?.viewModel.inputs.detailVC()
				} else {
					self?.viewModel.inputs.showFrequentsDetailVC()
				}
			}) .disposed(by: disposeBag)
	
	
		viewModel.outputs.frequentsList
					.bind { (List) in
						self.placeList = List
				} .disposed(by: disposeBag)

	}
		
}

extension SettingPlaceViewController: UITableViewDelegate {
		
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 99
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingPlaceTableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.1
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.1
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            guard let cell = tableView.cellForRow(at: indexPath) as? PlaceCell else { return }
			//edit
            success(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
//            self?.settingPlaceTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
			//self?.placeList.remove(at: indexPath.row)
			guard let self = self else {return}
			let frequent = self.placeList[indexPath.row]
			self.viewModel.inputs.removeFrequents(indexPath: indexPath, frequent: frequent)
			
            success(true)
        }
		return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
	}

}

extension SettingPlaceViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			if self.placeList.count > 5 {
				return 5
			}else {
				return self.placeList.count
			}
		} else {
			if self.placeList.count > 5 {
				return 0
			} else {
				return 5 - self.placeList.count
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if indexPath.section == 0 {
			let place = placeList[indexPath.row]
			let type: IconType = place.type
			let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath ) as! PlaceCell
			cell.placeNameLabel.text = place.name
			cell.placeAddressLabel.text = place.address
			cell.placeIconImageView.image = type.image
			
			cell.placeIconImageView.layer.cornerRadius = cell.placeIconImageView.frame.height / 2
			cell.placeIconImageView.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
			return cell
		}else {

			let cell = tableView.dequeueReusableCell(withIdentifier: "placeAddCell", for: indexPath) as! PlaceAddCell
			cell.placeAddButton.layer.cornerRadius = cell.placeAddButton.bounds.height/2
			cell.placeAddButton.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
			
			cell.placeAddLabel.text = "자주 가는 장소 등록"
			cell.viewModel = viewModel
			return cell
		}
	}
	
}



class PlaceAddCell: UITableViewCell {
	
	@IBOutlet var placeAddButton: UIButton!
	@IBOutlet var placeAddLabel: UILabel!
	var viewModel: SettingPlaceViewModel?
	
//	func configure(viewModel: SettingPlaceViewModel) {
//		self.viewModel = viewModel
//	}
	@IBAction func placeAddButton(_ sender: Any) {
		viewModel?.inputs.showFrequentsDetailVC()
	}
	
}

class PlaceCell: UITableViewCell{
	
	
	
	func configure(_ frequent: Frequent) {
        placeNameLabel.text = frequent.name
		placeAddressLabel.text = frequent.address
    }
	
	@IBOutlet var placeNameLabel: UILabel!
	@IBOutlet var placeAddressLabel: UILabel!
	@IBOutlet var placeIconImageView: UIImageView!
	
}
