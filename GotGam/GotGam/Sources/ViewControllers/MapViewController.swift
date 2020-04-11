//
//  MapViewController.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MapViewController: BaseViewController, ViewModelBindableType, MTMapViewDelegate {
    
    // MARK: - Properties
    
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    @IBOutlet var mapView: MTMapView!
    var poiItem1: MTMapPOIItem!
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSomePins()
        setCircle()
    }
    
    // MARK: - Initializing
    
    func configureMapView() {
        
        mapView = MTMapView.init(frame: mapView.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard

    }
    
    func setSomePins(){
        poiItem1 = MTMapPOIItem()
        poiItem1.itemName = "City on a Hill"
        poiItem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.541889, longitude: 127.095388))
        poiItem1.showDisclosureButtonOnCalloutBalloon = true
        poiItem1.markerType = .redPin
        poiItem1.showAnimationType = .dropFromHeaven;
        poiItem1.draggable = true
        poiItem1.tag = 1;

        mapView.add(poiItem1)
        mapView.fitArea(toShowMapPoints: [poiItem1.mapPoint!])
        
        
    }
    
    func setCircle(){
        let circle = MTMapCircle()
        circle.circleCenterPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.541889, longitude: 127.095388))
        circle.circleLineColor = .red
        circle.circleFillColor = UIColor.green.withAlphaComponent(0.5)
        circle.tag = 1234
        circle.circleRadius = 500
        mapView.addCircle(circle)
        mapView.fitArea(toShow: circle)
    }
    
    func bindViewModel() {
        
    }
    
    func mapView(_ mapView: MTMapView!, openAPIKeyAuthenticationResultCode resultCode: Int32, resultMessage: String!) {
        print(resultCode)
    }
}
