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
	
	var gotList: [Got] = [] {
		didSet{
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	var filteredList: [Got] = [] {
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
	}
	
	func bindViewModel() {
		searchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				let keyword = self.searchBar.text ?? ""
				self.viewModel.inputs.addKeyword(keyword: keyword)
			}) .disposed(by: disposeBag)
		
		searchBar.rx.text.orEmpty.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		
		searchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
			let text = self.searchBar.text ?? ""
			self.searchKeyword(keyword: text)
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
		return 3
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			if searchBar.text == "" {
				return self.historyList.count
			} else {
				return 3
			}
		}else if section == 1 {
			if searchBar.text == "" {
				return 0
			} else {
				if self.searchBar.text!.count > 0{
					return filteredList.count
				} else {
					return 0
				}
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
			let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! SearchHistoryCell
			cell.historyLabel.text = historyList[indexPath.row]
			return cell
		}else if indexPath.section == 2 {
			let place = placeList[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchKakaoCell
			cell.kewordLabel.text = place.placeName
			cell.resultLabel.text = place.addressName
			return cell
		} else {
			
			if searchBar.text!.count > 0 {
				let got = filteredList[indexPath.row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "gotCell", for: indexPath) as! GotCell
				cell.gotColor.backgroundColor = got.tag?.first?.hex.hexToColor()
				cell.gotLabel.text = got.title
			
				cell.gotColor.layer.cornerRadius = cell.gotColor.frame.height / 2
				return cell
			}else{
				let got = gotList[indexPath.row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "gotCell", for: indexPath) as! GotCell
				cell.gotColor.backgroundColor = got.tag?.first?.hex.hexToColor()
				cell.gotLabel.text = got.title
				cell.gotColor.layer.cornerRadius = cell.gotColor.frame.height / 2
				return cell
			}
		}
	}
	
}

extension FrequentsSearchViewController: UITableViewDelegate{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 2 {
			let place = self.placeList[indexPath.row]
			viewModel.inputs.placeBehavior.accept(place)
			viewModel.inputs.showMapVC()
		}
		
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
			viewModel.inputs.showMapVC()
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

class SearchCell: UITableViewCell{
	@IBOutlet var kewordLabel: UILabel!
}

