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
import CoreLocation
import UserNotifications
class MapViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    @IBOutlet weak var stackView: UIStackView!
    
    var viewModel: MapViewModel!
    var locationManager: LocationManager!
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager.shared
        locationManager.delegate = self
        locationManager.startBackgroundUpdates()
        
    }
    
    // MARK: - Initializing
    
    func bindViewModel() {
        
    }
    
    
}
extension MapViewController: LocationManagerDelegate{
    func locationUpdated(coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        let label = UILabel()
        label.text = "\(coordinate.latitude), \(coordinate.longitude)"
        self.stackView.addArrangedSubview(label)
    }
    func locationAuthenticationChanged(location: CLAuthorizationStatus) {
        if location == .authorizedAlways || location == .authorizedWhenInUse{
            let homeRegion = CLCircularRegion(center: .init(latitude: 37.38862618497263, longitude: 127.112923259607098), radius: 50, identifier: "enterHome")
            homeRegion.notifyOnEntry = true
            homeRegion.notifyOnExit = false
            let otherRegion = CLCircularRegion(center: .init(latitude: 37.392272935016805, longitude: 127.11687829282477), radius: 50, identifier: "enterOther")
            otherRegion.notifyOnEntry = true
            otherRegion.notifyOnExit = false
            
            locationManager.addRegionToMinotir(region: homeRegion)
            locationManager.addRegionToMinotir(region: otherRegion)
        }
    }
    
    
}
