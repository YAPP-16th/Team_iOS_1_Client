//
//  SearchBarViewController.swift
//  GotGam
//
//  Created by 김삼복 on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchBarViewController: BaseViewController, ViewModelBindableType {
	
	var viewModel: SearchBarViewModel!
	
	@IBOutlet var SearchBar: UITextField!
	@IBAction func moveMap(_ sender: Any) {
		self.dismiss(animated: true)
	}
	@IBOutlet weak var tableView: UITableView!
	
	var placeList: [Place] = [] {
		didSet{
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		//SearchBar.becomeFirstResponder()
		
		SearchBar.rx.text.orEmpty.debounce(.seconds(2), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		
	}
	
	
	func bindViewModel() {
	}
	
	
	func searchKeyword(keyword: String){
		APIManager.shared.search(keyword: keyword) { placeList in
			let place = placeList.first!
			print(place.addressName)
			self.placeList = placeList
		}
	}
	
}
extension SearchBarViewController: UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.placeList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let place = placeList[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.text = place.addressName
		return cell
	}
}
