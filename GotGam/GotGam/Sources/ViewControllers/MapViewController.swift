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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
    }
    
    // MARK: - Initializing
    
    func configureMapView() {
        
        mapView = MTMapView()
        mapView.delegate = self
        mapView.baseMapType = .standard

    }
    
    func bindViewModel() {
        
    }
}
