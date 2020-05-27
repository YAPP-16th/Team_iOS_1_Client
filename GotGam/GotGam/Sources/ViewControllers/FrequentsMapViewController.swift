//
//  FrequentsMapViewController.swift
//  GotGam
//
//  Created by 김삼복 on 27/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FrequentsMapViewController: BaseViewController, ViewModelBindableType {

	var viewModel: FrequentsMapViewModel!
	
	//search value
	var x: Double = 0.0
	var y: Double = 0.0
	var addressName: String = ""
	var placeName: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bindViewModel() {
		
	}
}
