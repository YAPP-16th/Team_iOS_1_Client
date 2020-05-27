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
	
	//search value
	var x: Double = 0.0
	var y: Double = 0.0
	var addressName: String = ""
	var placeName: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureMapView()
	}
	
	func configureMapView() {
		mapView = MTMapView.init(frame: self.mapBackgroundView.frame)
		mapView.delegate = self
		mapView.baseMapType = .standard
		self.mapBackgroundView.addSubview(mapView)
		self.mapBackgroundView.sendSubviewToBack(mapView)
	}
	
	
	func bindViewModel() {
		
	}
	
	@IBOutlet var mapBackgroundView: UIView!
}

