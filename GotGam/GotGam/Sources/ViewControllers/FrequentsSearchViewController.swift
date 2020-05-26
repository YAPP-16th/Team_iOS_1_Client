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
		viewModel.sceneCoordinator.close(animated: true)
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

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.hidesBackButton = true
		
		searchBar.becomeFirstResponder()
		
		searchBar.rx.text.orEmpty.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		
		searchBar.rx.controlEvent(.primaryActionTriggered).subscribe(onNext: {
			let text = self.searchBar.text ?? ""
			self.searchKeyword(keyword: text)
			}).disposed(by: disposeBag)
	}
	
	func bindViewModel() {
		self.searchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				let keyword = self.searchBar.text ?? ""
				self.viewModel.inputs.addKeyword(keyword: keyword)
			}) .disposed(by: disposeBag)
	}
	
	func searchKeyword(keyword: String){
		APIManager.shared.search(keyword: keyword) { placeList in
			self.placeList = placeList
		}
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
}

class SearchCell: UITableViewCell{
	@IBOutlet var kewordLabel: UILabel!
}

