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
import CoreLocation

class FrequentsMapViewController: BaseViewController, ViewModelBindableType, MTMapViewDelegate {

	var viewModel: FrequentsMapViewModel!
	var mapView: MTMapView!
	@IBOutlet var addressView: UIView!
	@IBOutlet var placeLabel: UILabel!
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var currentBtn: UIButton!
	@IBOutlet var okay: UIButton!
	@IBAction func okay(_ sender: UIButton) {
		if viewModel?.placeBehavior.value != nil {
			viewModel.frequentsPlaceMap.accept(viewModel?.placeBehavior.value)
		}
		for controller in self.navigationController!.viewControllers as Array {
			if controller.isKind(of: FrequentsViewController.self) {
				_ =  self.navigationController!.popToViewController(controller, animated: true)
				break
			}
		}
	}
	@IBAction func currentBtn(_ sender: Any) {
		setMyLocation()
	}
	
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
		currentBtn.layer.cornerRadius = currentBtn.frame.height / 2
		currentBtn.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.addPin()
		
		guard let currentLocation = LocationManager.shared.currentLocation else { return }
		if viewModel.placeBehavior.value == nil {
			APIManager.shared.getPlace(longitude: currentLocation.longitude, latitude: currentLocation.latitude) { [weak self] (place) in
				if place?.roadAddress != nil {
					if place?.roadAddress?.buildingName == "" {
						self?.placeLabel.text = place!.roadAddress?.addressName
						self?.addressLabel.text = place!.roadAddress?.addressName
					} else {
						self?.placeLabel.text = place!.roadAddress?.buildingName
						self?.addressLabel.text = place!.roadAddress?.addressName
					}
				} else {
						self?.placeLabel.text = place!.address?.addressName
						self?.addressLabel.text = place!.address?.addressName
					}

			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let place = viewModel.placeBehavior.value, let pX = place.x, let pY = place.y {
			x = Double(pX)!
			y = Double(pY)!
			updateAddress()
		} else {
			setMyLocation()
		}
	}
	
	func configureMapView() {
		mapView = MTMapView.init(frame: self.view.frame)
		mapView.delegate = self
		mapView.baseMapType = .standard
		self.view.addSubview(mapView)
		self.view.sendSubviewToBack(mapView)
	}
	
	
	func bindViewModel() {
		viewModel.placeBehavior
			.compactMap { $0?.placeName }
			.bind(to: placeLabel.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.placeBehavior
			.compactMap { $0?.addressName }
			.bind(to: addressLabel.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.placeBehavior
			.bind(to: viewModel.frequentsPlaceMap)
			.disposed(by: disposeBag)
		
//		viewModel.currentPlace
//			.compactMap { $0?.placeName }
//			.bind(to: placeLabel.rx.text)
//			.disposed(by: disposeBag)
//
//		viewModel.currentPlace
//			.compactMap { $0?.addressName }
//			.bind(to: addressName.rx.text)
//			.disposed(by: disposeBag)
	}
	
	func setMyLocation(){
        LocationManager.shared.requestAuthorization()
        if LocationManager.shared.locationServicesEnabled {
            let status = LocationManager.shared.authorizationStatus
            switch status{
            case .denied:
              print("거부됨")
            case .notDetermined, .restricted:
                print("설정으로 이동시키기")
            case .authorizedWhenInUse, .authorizedAlways:
                self.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: LocationManager.shared.currentLocation!.latitude, longitude: LocationManager.shared.currentLocation!.longitude)), animated: true)
            }
            
        }
    }
	
	func updateAddress() {
		self.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: y, longitude: x)), animated: true)
	}
	
	func addPin(){
        mapView.removeAllPOIItems()
            let pin = MTMapPOIItem()
			pin.itemName = placeName
            pin.markerType = .customImage
            pin.customImage = UIImage(named: "icPin1")
            pin.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: y, longitude: x))
            mapView.addPOIItems([pin])
    }
	
}

