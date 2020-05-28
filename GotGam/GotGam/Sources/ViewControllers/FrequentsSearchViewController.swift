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
		
		searchBar.rx.controlEvent(.primaryActionTriggered).subscribe(onNext: {
			let text = self.searchBar.text ?? ""
			self.searchKeyword(keyword: text)
			}).disposed(by: disposeBag)
		
		
	}
	
	func searchKeyword(keyword: String){
		APIManager.shared.search(keyword: keyword) { placeList in
			self.placeList = placeList
		}
	}
	
	func setCollectionItems() {NSLog("setCollectionItems")
		collectionItems = ["내위치", "지도에서 선택"]
	}

}

extension FrequentsSearchViewController: UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return self.placeList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let place = placeList[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
			cell.kewordLabel.text = place.placeName
			return cell
	}
	
}

extension FrequentsSearchViewController: UITableViewDelegate{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let place = self.placeList[indexPath.row]
		viewModel.inputs.placeBehavior.accept(place)
		viewModel.inputs.showMapVC()
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

