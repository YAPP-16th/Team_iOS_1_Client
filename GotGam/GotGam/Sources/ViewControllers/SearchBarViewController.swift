//
//  SearchBarViewController.swift
//  GotGam
//
//  Created by 김삼복 on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

class SearchBarViewController: UIViewController, ViewModelBindableType {
	
	var viewModel: SearchBarViewModel!
	
	@IBOutlet var SearchBar: UITextField!
	@IBAction func moveMap(_ sender: Any) {
		self.dismiss(animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		SearchBar.becomeFirstResponder()
		
		APIManager.shared.search(keyword: "카카오") { placeList in
			let place = placeList.first!
//			print(place.addressName)
		}
		
	}
	
	func bindViewModel() {
		
	}
	
	func initTextField() {
//		// editingChanged 이벤트가 발생 했을 때
//		self.SearchBar.rx.controlEvent([.editingChanged])
//			.asObservable() .subscribe(onNext: { _ in
//				print("editingChanged : \(self.textField.text ?? "")") })
//			.disposed(by: DisposeBag)
//		// textField.rx.text의 변경이 있을 때
//		self.SearchBar.rx.text .subscribe(onNext: { newValue in print("rx.text subscribe : \(newValue ?? "")") }).disposed(by: disposeBag)
//		// textField.text의 변경이 있을 때
//		self.SearchBar.rx.observe(String.self, "text") .subscribe(onNext: { newValue in print("observe text : \(newValue ?? "")") }).disposed(by: disposeBag)

	}

}
