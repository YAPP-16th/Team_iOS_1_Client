//
//  FrequentsSearchViewController.swift
//  GotGam
//
//  Created by 김삼복 on 26/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FrequentsSearchViewController: BaseViewController, ViewModelBindableType{
	var viewModel: FrequentsSearchViewModel!
	
	@IBAction func moveBack(_ sender: Any) {
		viewModel.sceneCoordinator.close(animated: true, completion: nil)
	}
	
	@IBOutlet var searchBar: UITextField!
	@IBOutlet var tableView: UITableView!
	
	var placeList: [Place] = [] {
		didSet{
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	var historyList: [String] = [] {
		didSet{
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	var collectionItems = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.hidesBackButton = true
		
		searchBar.becomeFirstResponder()
		
		setCollectionItems()
		
		searchBar.borderStyle = .none
		
		viewModel.inputs.readKeyword()
	}

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.isNavigationBarHidden = true
	}
	
	func bindViewModel() {
		searchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				let keyword = self.searchBar.text ?? ""
				if !keyword.isEmpty && keyword != ""{
					self.viewModel.inputs.addKeyword(keyword: keyword)
					self.searchKeyword(keyword: keyword)
					self.historyList.insert(keyword, at: 0)
				}
			}) .disposed(by: disposeBag)
		
		searchBar.rx.text.orEmpty.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		
		viewModel.outputs.keywords
			.bind { (List) in
				self.historyList = List
			} .disposed(by: disposeBag)
		
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.section == 0{
					self?.searchBar.text = self?.historyList[indexPath.row]
					let keyword = self?.searchBar.text ?? ""
					if !keyword.isEmpty && keyword != ""{
						self?.viewModel.inputs.addKeyword(keyword: keyword)
					}
					self?.searchKeyword(keyword: keyword)
				}
			}).disposed(by: disposeBag)
		
	}
	
	func searchKeyword(keyword: String){
		guard let location = LocationManager.shared.currentLocation else { return }
		APIManager.shared.search(keyword: keyword, latitude: location.latitude, longitude: location.longitude) { placeList in
			self.placeList = placeList
		}
	}
	
	func setCollectionItems() {NSLog("setCollectionItems")
		collectionItems = ["내위치", "지도에서 선택"]
	}

}

extension FrequentsSearchViewController: UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			if searchBar.text == "" {
				return self.historyList.count
			} else {
				return historyList.count <= 3 ? historyList.count : 3
			}
		}else {
			if searchBar.text == "" {
				return 0
			} else {
				return self.placeList.count
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "historyFCell", for: indexPath) as! FrequentHistoryCell
			cell.historyLabel.text = historyList[indexPath.row]
			return cell
		}else {
			let place = placeList[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchFCell", for: indexPath) as! FrequentSearchCell
			cell.kewordLabel.text = place.placeName
			return cell
		}
	}
	
}

extension FrequentsSearchViewController: UITableViewDelegate{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 {
			let place = self.placeList[indexPath.row]
			viewModel.inputs.placeBehavior.accept(place)
			viewModel.inputs.showMapVC()
		}
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
		let text = self.searchBar.text ?? ""
		if text != "" && !text.isEmpty {
			if section == 0 {
				view.backgroundColor = .lightGray
			} else {
				view.backgroundColor = .clear
			}
		}
        return view
    }
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.5
	}
	
}

extension FrequentsSearchViewController: UICollectionViewDataSource{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionItems.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoveMapCell", for: indexPath) as! MoveMapCell
		cell.collectionLabel.text = collectionItems[indexPath.row]
		if indexPath.row == 1 {
			cell.collectionicon.image = UIImage(named:"icFrequentsSearch")
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.row == 0{
			guard let currentLocation = LocationManager.shared.currentLocation else { return }
			APIManager.shared.getPlace(longitude: currentLocation.longitude, latitude: currentLocation.latitude) { [weak self] (place) in
				var tempPlace = place
				tempPlace?.x = String(currentLocation.latitude)
				tempPlace?.y = String(currentLocation.longitude)
				self?.viewModel.frequentsPlaceSearch.accept(tempPlace)
				
				self?.viewModel.moveFrequentsVC()
			}
		}else {
			viewModel.inputs.showMapVC()
		}
		
	}

}

extension FrequentsSearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if indexPath.row == 0{
			return CGSize(width: 100, height: 48)
		} else {
			return CGSize(width: 150, height: 48)
		}
	}
}

class MoveMapCell: UICollectionViewCell{
	@IBOutlet var collectionicon: UIImageView!
	@IBOutlet var collectionLabel: UILabel!
}

class FrequentSearchCell: UITableViewCell{
	@IBOutlet var kewordLabel: UILabel!
}

class FrequentHistoryCell: UITableViewCell {
	@IBOutlet var historyLabel: UILabel!
}
