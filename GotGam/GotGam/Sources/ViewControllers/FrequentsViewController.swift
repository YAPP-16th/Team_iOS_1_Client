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

	enum State{
		case create
		case update
	}
	var viewModel: FrequentsViewModel!
	
	@IBOutlet var placeName: UITextField!
	@IBOutlet var placeAddress: UITextField!
	@IBOutlet var addFrequents: UIBarButtonItem!
	
	@IBOutlet var icHomeBtn: UIButton!
	@IBOutlet var icOfficeBtn: UIButton!
	@IBOutlet var icSchoolBtn: UIButton!
	@IBOutlet var icOtherBtn: UIButton!
	
	@IBOutlet var textNum: UILabel!
	
	var state: State = .create
	
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

		if var frequents = self.viewModel.frequentOrigin{
			//Update logic
			placeName.text = frequents.name
			placeAddress.text = frequents.address
			self.viewModel.inputs.typePlace.accept(frequents.type)
			
			if frequents.type == .home {
				self.icHomeBtn.backgroundColor = UIColor.saffron
			} else if frequents.type == .office {
				self.icOfficeBtn.backgroundColor = UIColor.saffron
			} else if frequents.type == .school {
				self.icSchoolBtn.backgroundColor = UIColor.saffron
			} else {
				self.icOtherBtn.backgroundColor = UIColor.saffron
			}
			
			self.state = .update
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		navigationController?.isNavigationBarHidden = false
		navigationController?.interactivePopGestureRecognizer?.delegate = nil
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
	
	func bindViewModel() {
		
		placeName.rx.text.orEmpty
			.bind(to: viewModel.inputs.namePlace)
			.disposed(by: disposeBag)
		
		placeAddress.rx.text.orEmpty
			.bind(to: viewModel.inputs.addressPlace)
			.disposed(by: disposeBag)

		placeAddress.rx.controlEvent(.touchDown)
			.asObservable().subscribe(onNext:{ _ in
				self.viewModel.inputs.moveSearchVC()
			})
			.disposed(by: disposeBag)
		
		addFrequents.rx.tap
			.subscribe(onNext: { [weak self] in
				switch self?.state{
					case .create:
						self?.viewModel.addFrequents()
					case .update:
						self?.viewModel.updateFrequents()
					case .none: break
				}
			}).disposed(by: disposeBag)

		//도로명 주소 있을 때
		viewModel.frequentsPlace
			.compactMap { $0?.addressName }
			.bind(to: placeAddress.rx.text)
			.disposed(by: disposeBag)

		viewModel.frequentsPlace
			.compactMap { $0?.addressName }
			.bind(to: viewModel.addressPlace)
			.disposed(by: disposeBag)

		//도로명 주소 없을 때
		viewModel.frequentsPlace
			.compactMap { $0?.address?.addressName }
			.bind(to: placeAddress.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.frequentsPlace
			.compactMap { $0?.address?.addressName }
			.bind(to: viewModel.addressPlace)
			.disposed(by: disposeBag)
		
		//경도 위도 
		viewModel.frequentsPlace
			.compactMap { $0?.x }
			.bind(to: viewModel.latitudePlace)
			.disposed(by: disposeBag)

		viewModel.frequentsPlace
			.compactMap { $0?.y }
			.bind(to: viewModel.longitudePlace)
			.disposed(by: disposeBag)
		
		viewModel.addressPlace
			.bind(to: placeAddress.rx.text)
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
		
		placeName.rx.text
			.subscribe(onNext: { [weak self] (text) in
				self?.textNum.text = "\(text!.count)"
			}).disposed(by: disposeBag)
		
		Observable.combineLatest(viewModel.namePlace, viewModel.addressPlace, viewModel.inputs.typePlace)
		.subscribe(onNext: {[weak self] name, address, type in
			print(name, address, type)
			if name.isEmpty || address.isEmpty || type == nil{
				self?.addFrequents.isEnabled = false
			} else {
				self?.addFrequents.isEnabled = true
			}
		})
		.disposed(by: disposeBag)
	}
	

}

extension FrequentsViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let textFieldText = textField.text,
			let rangeOfTextToReplace = Range(range, in: textFieldText) else {
				return false
		}
		let substringToReplace = textFieldText[rangeOfTextToReplace]
		let count = textFieldText.count - substringToReplace.count + string.count
		return count <= 15
	}
	
	
}
