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
	@IBAction func icHome(_ sender: Any) {
		icHomeBtn.backgroundColor = UIColor.saffron
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		icHomeBtn.layer.cornerRadius = self.icHomeBtn.frame.height / 2


	}

	
	func bindViewModel() {
		
		placeName.rx.text.orEmpty
			.bind(to: viewModel.inputs.namePlace)
			.disposed(by: disposeBag)

		placeAddress.rx.text.orEmpty
			.bind(to: viewModel.inputs.addressPlace)
			.disposed(by: disposeBag)

		addFrequents.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.viewModel.inputs.addFrequents()
				self?.viewModel.sceneCoordinator.close(animated: true)
			}).disposed(by: disposeBag)

	
		
	}
	

}
