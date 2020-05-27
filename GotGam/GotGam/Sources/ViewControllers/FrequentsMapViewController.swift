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

class FrequentsMapViewController: BaseViewController, ViewModelBindableType, MTMapViewDelegate {

	var viewModel: FrequentsMapViewModel!
	var mapView: MTMapView!
	@IBOutlet var addressView: UIView!
	@IBOutlet var placeLabel: UILabel!
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var okay: UIButton!
	
	//search value
	var x: Double = 0.0
	var y: Double = 0.0
	var addressName: String = ""
	var placeName: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureMapView()
		
		addressView.layer.masksToBounds = true
		addressView.layer.cornerRadius = 17
		okay.layer.cornerRadius = 17
	}
	
	func configureMapView() {
		mapView = MTMapView.init(frame: self.view.frame)
		mapView.delegate = self
		mapView.baseMapType = .standard
		self.view.addSubview(mapView)
		self.view.sendSubviewToBack(mapView)
	}
	
	
	func bindViewModel() {
		
	}
	
	
}

