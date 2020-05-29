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
		viewModel.sceneCoordinator.close(animated: true, completion: nil)
	}
	@IBOutlet weak var tableView: UITableView!
	
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
	
	var collectionList = [Frequent]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		SearchBar.becomeFirstResponder()
		
		SearchBar.rx.text.orEmpty.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		SearchBar.rx.controlEvent(.primaryActionTriggered).subscribe(onNext: {
			let text = self.SearchBar.text ?? ""
			self.historyList.insert(text, at: 0)
			self.searchKeyword(keyword: text)
			}).disposed(by: disposeBag)
		
		self.viewModel.inputs.readKeyword()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.inputs.readFrequents()
	}
	
	func bindViewModel() {
		
		self.viewModel.outputs.keywords.bind { (List) in
			self.historyList = List
			} .disposed(by: disposeBag)
		
		self.SearchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				var keyword = self.SearchBar.text ?? ""
				self.viewModel.inputs.addKeyword(keyword: keyword)
			}) .disposed(by: disposeBag)
		
		viewModel.outputs.collectionItems
			.subscribe(onNext: { [weak self] frequents in
				self?.collectionList = frequents
			})
			.disposed(by: disposeBag)

	}
	
	
	func searchKeyword(keyword: String){
		guard let location = LocationManager.shared.currentLocation else { return }
		APIManager.shared.search(keyword: keyword, latitude: location.latitude, longitude: location.longitude) { placeList in
			self.placeList = placeList
		}
	}
	
}

extension SearchBarViewController: UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			if self.historyList.count > 3 {
				return 3
			} else { return self.historyList.count }
//			return historyList.count + placeList.count
		}else{
			return self.placeList.count
		}
		
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let history = historyList[indexPath]
//		let type: HistoryType = HistoryType(rawValue: history.type)
//
//		switch type {
//			case .search:
//				let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchKakaoCell
//				cell.imageView.image = type.image
//
//			case .got:
//
//		}
//		if historyList[indexPath].type == .search {
//			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchKakaoCell
//		} else if == .got {
//
//		}

		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! SearchHistoryCell
			cell.historyLabel.text = historyList[indexPath.row]
			return cell
		}else{
			let place = placeList[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchKakaoCell
			cell.kewordLabel.text = place.placeName
			cell.resultLabel.text = place.addressName
			return cell
		}
	}
}

class SearchHistoryCell: UITableViewCell {
	@IBOutlet var historyLabel: UILabel!
}

class SearchKakaoCell: UITableViewCell {
	@IBOutlet var kewordLabel: UILabel!
	@IBOutlet var resultLabel: UILabel!
}

class FrequentsCollectionCell: UICollectionViewCell {
	@IBOutlet var frequentsIcon: UIButton!
	@IBOutlet var frequentsLabel: UILabel!
}


extension SearchBarViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 {
			return 90
		} else { return 48 }
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 {
			let place = self.placeList[indexPath.row]
			if let tabVC = self.presentingViewController as? TabBarController{
				let mapVC = tabVC.viewControllers?.first as? MapViewController
				mapVC?.x = Double(place.x!)!
				mapVC?.y = Double(place.y!)!
				mapVC?.placeName = place.placeName!
				mapVC?.addressName = place.addressName!
				
				viewModel.sceneCoordinator.close(animated: true) {
					mapVC?.updateAddress()
				}
			}
		}
	}
}

extension SearchBarViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrequentsCollectionCell", for: indexPath) as! FrequentsCollectionCell
		cell.frequentsLabel.text = collectionList[indexPath.row].name
		cell.frequentsIcon.setImage(collectionList[indexPath.row].type.image, for: .normal)
		cell.frequentsIcon.layer.cornerRadius = cell.frequentsIcon.frame.height / 2
		return cell
	}
}

extension SearchBarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
		let rect = NSString(string: "\(self.collectionList[indexPath.item].name)").boundingRect(with: .init(width: 0, height: 48), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)

		let width: CGFloat = 8 + 16 + 7 + rect.width + 8
        // cell height - inset(10)
        let height: CGFloat = 48
        return CGSize(width: width, height: height)
    }
}
