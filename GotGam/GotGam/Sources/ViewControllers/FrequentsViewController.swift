//
//  FrequentsViewController.swift
//  GotGam
//
//  Created by 김삼복 on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FrequentsViewController: BaseViewController, ViewModelBindableType {

	var viewModel: FrequentsViewModel!
	
	@IBOutlet var placeName: UITextField!
	@IBOutlet var placeAddress: UITextField!
	@IBOutlet var addFrequents: UIBarButtonItem!
	
	@IBOutlet var icHomeBtn: UIButton!
	@IBOutlet var icOfficeBtn: UIButton!
	@IBOutlet var icSchoolBtn: UIButton!
	@IBOutlet var icOtherBtn: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		icHomeBtn.layer.cornerRadius = self.icHomeBtn.frame.height / 2
		icHomeBtn.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
		icOfficeBtn.layer.cornerRadius = self.icHomeBtn.frame.height / 2
		icOfficeBtn.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
		icSchoolBtn.layer.cornerRadius = self.icHomeBtn.frame.height / 2
		icSchoolBtn.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
		icOtherBtn.layer.cornerRadius = self.icHomeBtn.frame.height / 2
		icOtherBtn.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
		
		placeName.layer.masksToBounds = true
		placeName.layer.borderColor = UIColor.saffron.cgColor
		placeName.layer.borderWidth = 1.0
		placeName.layer.cornerRadius = 17
		placeAddress.layer.masksToBounds = true
		placeAddress.layer.borderColor = UIColor.saffron.cgColor
		placeAddress.layer.borderWidth = 1.0
		placeAddress.layer.cornerRadius = 17
	}
	
	func bindViewModel() {
		
		placeName.rx.text.orEmpty
			.bind(to: viewModel.inputs.namePlace)
			.disposed(by: disposeBag)

		placeAddress.rx.controlEvent(.touchDown)
			.asObservable().subscribe(onNext:{ _ in
				self.viewModel.inputs.moveSearchVC()
			})
			.disposed(by: disposeBag)
		
		addFrequents.rx.tap
			.subscribe(onNext: { [weak self] in
				
				self?.viewModel.inputs.addFrequents()
				self?.viewModel.sceneCoordinator.close(animated: true, completion: nil)
			}).disposed(by: disposeBag)

		viewModel.frequentsPlace
			.compactMap { $0?.addressName }
			.bind(to: placeAddress.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.frequentsPlace
			.compactMap { $0?.addressName }
			.bind(to: viewModel.addressPlace)
			.disposed(by: disposeBag)
		
		viewModel.frequentsPlace
			.compactMap { $0?.x }
			.bind(to: viewModel.latitudePlace)
			.disposed(by: disposeBag)
			
		viewModel.frequentsPlace
			.compactMap { $0?.y }
			.bind(to: viewModel.longitudePlace)
			.disposed(by: disposeBag)
		
		icHomeBtn.rx.tap
			.subscribe({ [weak self] _ in
				self?.viewModel.inputs.typePlace.accept(.home)
				self?.icHomeBtn.backgroundColor = UIColor.saffron
				self?.icOfficeBtn.backgroundColor = UIColor.brownGrey
				self?.icSchoolBtn.backgroundColor = UIColor.brownGrey
				self?.icOtherBtn.backgroundColor = UIColor.brownGrey
			}).disposed(by: disposeBag)
		
		icOfficeBtn.rx.tap
		.subscribe({ [weak self] _ in
			self?.viewModel.inputs.typePlace.accept(.office)
			self?.icHomeBtn.backgroundColor = UIColor.brownGrey
			self?.icOfficeBtn.backgroundColor = UIColor.saffron
			self?.icSchoolBtn.backgroundColor = UIColor.brownGrey
			self?.icOtherBtn.backgroundColor = UIColor.brownGrey
		}).disposed(by: disposeBag)
		
		icSchoolBtn.rx.tap
		.subscribe({ [weak self] _ in
			self?.viewModel.inputs.typePlace.accept(.school)
			self?.icHomeBtn.backgroundColor = UIColor.brownGrey
			self?.icOfficeBtn.backgroundColor = UIColor.brownGrey
			self?.icSchoolBtn.backgroundColor = UIColor.saffron
			self?.icOtherBtn.backgroundColor = UIColor.brownGrey
		}).disposed(by: disposeBag)
		
		icOtherBtn.rx.tap
		.subscribe({ [weak self] _ in
			self?.viewModel.inputs.typePlace.accept(.other)
			self?.icHomeBtn.backgroundColor = UIColor.brownGrey
			self?.icOfficeBtn.backgroundColor = UIColor.brownGrey
			self?.icSchoolBtn.backgroundColor = UIColor.brownGrey
			self?.icOtherBtn.backgroundColor = UIColor.saffron
		}).disposed(by: disposeBag)
	}
	

}
