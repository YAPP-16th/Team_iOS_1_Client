//
//  AddMapViewController.swift
//  GotGam
//
//  Created by woong on 2020/06/01.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddMapViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: AddMapViewModel!
    
    // MARK: - Methods
    
    func drawCircle(latitude: Double, longitude: Double, radius: Float) {
        
        mapView?.removeAllCircles()
        let circle = MTMapCircle()
        let center = MTMapPoint.init(geoCoord: .init(latitude: latitude, longitude: longitude))
        circle.circleCenterPoint = center
        circle.circleLineColor = .saffron
        circle.circleFillColor = UIColor.saffron.withAlphaComponent(0.17)
        circle.circleRadius = radius
        mapView?.addCircle(circle)
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
                guard let currentLocation = LocationManager.shared.currentLocation else { return }
                self.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocation.latitude, longitude: currentLocation.longitude)), animated: true)
            @unknown default:
                break
            }
            
        }else{
        }
    }
    @IBAction func didTapCurrentButton(_ sender: UIButton) {
        setMyLocation()
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.interactivePopGestureRecognizer?.delegate = nil
        configureMapView()
        configureViews()
        configureSlider()
        configureSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Initializing
    
    func bindViewModel() {
        Observable.combineLatest(viewModel.inputs.radiusRelay, viewModel.inputs.locationSubject)
            .subscribe(onNext: { [weak self] radius, location in
                self?.drawCircle(latitude: location.latitude, longitude: location.longitude, radius: Float(radius))
            })
            .disposed(by: disposeBag)
        
        seedingButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.seedSubject)
            .disposed(by: disposeBag)
        
        viewModel.outputs.movePoint
            .subscribe(onNext: { [weak self] point in
                self?.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: point.latitude, longitude: point.longitude)), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func configureMapView() {
        mapView = MTMapView(frame: mapBackgroundView.bounds)
        if let mapView = mapView {
            mapView.translatesAutoresizingMaskIntoConstraints = false
            mapView.delegate = self
            mapView.baseMapType = .standard
            mapBackgroundView.insertSubview(mapView, at: 0)
        }
    }
    
    func configureViews() {
        searchTextField.inputView = nil
        seedingButton.layer.cornerRadius = seedingButton.bounds.height/2
        currentButton.layer.cornerRadius = currentButton.bounds.height/2
    }
    
    func configureSlider() {
        radiusSliderView.radiusSlider.addTarget(self, action: #selector(didChangeRadius(slider:event:)), for: .valueChanged)
    }
    @objc func didChangeRadius(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                viewModel.inputs.radiusRelay.accept(Double(slider.value * 1000))
            case .ended:
                mapView?.fitAreaToShowAllCircleOverlays()
            default:
                break
            }
        }
    }
    
    func configureSearch() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchView))
        searchView.addGestureRecognizer(tapGesture)
    }
    @objc func didTapSearchView() {
        viewModel.inputs.searchTap.onNext(())
    }
    
    // MARK: - Views
    
    @IBOutlet var mapBackgroundView: UIView!
    var mapView: MTMapView?
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var radiusSliderView: RadiusSliderView!
    @IBOutlet var seedImageView: UIImageView!
    @IBOutlet var seedingButton: UIButton!
    @IBOutlet var currentButton: UIButton!
    @IBOutlet var searchView: UIView!
}

extension AddMapViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, centerPointMovedTo mapCenterPoint: MTMapPoint!) {
        let mp = mapCenterPoint.mapPointGeo()
        viewModel.inputs.locationSubject.accept(.init(latitude: mp.latitude, longitude: mp.longitude))
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        let mp = mapCenterPoint.mapPointGeo()
        viewModel.inputs.locationSubject.accept(.init(latitude: mp.latitude, longitude: mp.longitude))
    }
}
