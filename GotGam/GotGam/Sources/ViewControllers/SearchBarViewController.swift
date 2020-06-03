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
import RxDataSources

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
	
	var collectionList = [Frequent]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		SearchBar.becomeFirstResponder()
		
		self.viewModel.inputs.readKeyword()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.inputs.readFrequents()
		viewModel.inputs.readGot()
	}
	
	func bindViewModel() {
		
		SearchBar.rx.text.orEmpty.debounce(.seconds(1), scheduler: MainScheduler.instance)
			.subscribe(onNext: { text in
				self.searchKeyword(keyword: text)
			}).disposed(by: self.disposeBag)
		
		SearchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				let text = self.SearchBar.text ?? ""
				if !text.isEmpty && text != ""{
					self.historyList.insert(text, at: 0)
					self.searchKeyword(keyword: text)
				}
			}).disposed(by: disposeBag)
		
		self.viewModel.outputs.keywords.bind { (List) in
			self.historyList = List
			} .disposed(by: disposeBag)
		
		self.SearchBar.rx.controlEvent(.primaryActionTriggered)
			.subscribe(onNext: {
				let keyword = self.SearchBar.text ?? ""
				if !keyword.isEmpty && keyword != ""{
					self.viewModel.inputs.addKeyword(keyword: keyword)
				}
			}) .disposed(by: disposeBag)
		
		viewModel.outputs.collectionItems
			.subscribe(onNext: { [weak self] frequents in
				self?.collectionList = frequents
			})
			.disposed(by: disposeBag)

		tableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.section == 0{
					self?.SearchBar.text = self?.historyList[indexPath.row]
					let keyword = self?.SearchBar.text ?? ""
					if !keyword.isEmpty && keyword != ""{
						self?.viewModel.inputs.addKeyword(keyword: keyword)
					}
					self?.searchKeyword(keyword: keyword)
				}
			})
			.disposed(by: disposeBag)
		
		viewModel.gotList
			.subscribe(onNext: { [weak self] gotLists in
				self?.gotList = gotLists
			})
			.disposed(by: disposeBag)
		
		SearchBar.rx.text.orEmpty
			.subscribe(onNext: { [weak self] (text) in
				
				let filteredList = self?.gotList.filter ({ got -> Bool in
                    if got.title.lowercased().contains(text.lowercased()) {
                        return true
                    }
                    return false
                })
				
				self?.filteredList = filteredList ?? []
			}).disposed(by: disposeBag)
	}
	
	
	func searchKeyword(keyword: String){
		let location = LocationManager.shared.currentLocation
        APIManager.shared.search(keyword: keyword, latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0) { placeList in
			self.placeList = placeList
		}
	}
	
}


extension SearchBarViewController: UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			if SearchBar.text == "" {
				return self.historyList.count
			} else {
				return historyList.count <= 3 ? historyList.count : 3
			}
		}else if section == 1 {
			if SearchBar.text == "" {
				return 0
			} else {
				if self.SearchBar.text!.count > 0{
					return filteredList.count
				} else {
					return 0
				}
			}
		}else {
			if SearchBar.text == "" {
				return 0
			} else {
				return self.placeList.count
			}
		}	
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! SearchHistoryCell
			guard indexPath.row < historyList.count else {return UITableViewCell()}
			cell.historyLabel.text = historyList[indexPath.row]
			return cell
		}else if indexPath.section == 2 {
			let place = placeList[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchKakaoCell
			cell.kewordLabel.text = place.placeName
			cell.resultLabel.text = place.addressName
			return cell
		} else {
			
			if SearchBar.text!.count > 0 {
				let got = filteredList[indexPath.row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "gotCell", for: indexPath) as! GotCell
				cell.gotColor.backgroundColor = got.tag?.hex.hexToColor()
				cell.gotLabel.text = got.title
			
				cell.gotColor.layer.cornerRadius = cell.gotColor.frame.height / 2
				return cell
			}else{
				let got = gotList[indexPath.row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "gotCell", for: indexPath) as! GotCell
				cell.gotColor.backgroundColor = got.tag?.hex.hexToColor()
				cell.gotLabel.text = got.title
				cell.gotColor.layer.cornerRadius = cell.gotColor.frame.height / 2
				return cell
			}
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

class GotCell: UITableViewCell {
	@IBOutlet var gotColor: UIImageView!
	@IBOutlet var gotLabel: UILabel!
}

extension SearchBarViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 2 {
			return 90
		} else { return 48 }
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 2 {
			let place = self.placeList[indexPath.row]

            if let navVC = self.navigationController {
                let currentIndex = navVC.viewControllers.count-1
                if let _ = navVC.viewControllers[currentIndex-1] as? AddMapViewController {
                    
                    viewModel.sceneCoordinator.pop(animated: true, completion: {
                        self.viewModel.placeSubject.onNext(place)
                    })
                    
                }
            } else if let tabVC = self.presentingViewController as? TabBarController {
				let mapVC = tabVC.viewControllers?.first as? MapViewController
				mapVC?.x = Double(place.x!)!
				mapVC?.y = Double(place.y!)!
				mapVC?.placeName = place.placeName!
				mapVC?.addressName = place.addressName!
				
				viewModel.sceneCoordinator.close(animated: true) {
					mapVC?.updateAddress()
                }
            }
		} else if indexPath.section == 1 {
			let got = self.gotList[indexPath.row]
			if let tabVC = self.presentingViewController as? TabBarController{
				let mapVC = tabVC.viewControllers?.first as? MapViewController
				mapVC?.x = got.longitude
				mapVC?.y = got.latitude
				
				viewModel.sceneCoordinator.close(animated: true) {
					let index = self.gotList.firstIndex(of: got)
					mapVC?.setCard(index: index!)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
		view.backgroundColor = .clear
        return view
    }
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.1
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

		let width: CGFloat = 16 + 16 + 7 + rect.width + 8
        let height: CGFloat = 48
        return CGSize(width: width, height: height)
    }
}

extension SearchBarViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let frequents = self.collectionList[indexPath.row]
		if let tabVC = self.presentingViewController as? TabBarController{
			let mapVC = tabVC.viewControllers?.first as? MapViewController
			mapVC?.x = frequents.latitude
			mapVC?.y = frequents.longitude
			mapVC?.placeName = frequents.name
			mapVC?.addressName = frequents.address
			viewModel.sceneCoordinator.close(animated: true) {
				mapVC?.updateAddress()
			}
		}
	}
}
