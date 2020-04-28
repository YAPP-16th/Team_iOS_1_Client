//
//  AddViewController.swift
//  GotGam
//
//  Created by woong on 26/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import CoreLocation

enum InputItem: CaseIterable {
    case tag
    case endDate
    case alramMsg
    
    var title: String {
        switch self {
        case .tag:     return "태그"
        case .endDate:  return "마감 일시"
        case .alramMsg: return "알림 메세지"
        }
    }
    
    var placeholder: String {
        switch self {
        case .tag:     return "미지정"
        case .endDate:  return "언제까지 가야할지 알려주세요"
        case .alramMsg: return "알려줄 내용을 적어주세요"
        }
    }
}


class AddViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: AddViewModel!
    var currentCenter: MTMapPoint = MTMapPoint(geoCoord: .init(latitude: 37.42462158203125, longitude: 126.74259919223122))
    var currentCenterLocation = CLLocationCoordinate2D(latitude: 37.42462158203125, longitude: 126.74259919223122)
    let locationManager = CLLocationManager()

    // MARK: - Methods
    
    
    func drawCircle(center: MTMapPoint, radius: Float) {
        let circle = MTMapCircle()
        circle.circleCenterPoint = center
        circle.circleLineColor = .orange
        //circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        circle.circleFillColor = .clear
        circle.circleRadius = radius
        
        
        
        mapOutsideView.isHidden = true
        
        print(radius, CGFloat(radius))
        //mapOutsideView.backgroundColor = UIColor.b
        
        let shape = CAShapeLayer()
        let path = UIBezierPath(rect: mapOutsideView.bounds)
        path.addArc(withCenter: mapOutsideView.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        shape.path = path.cgPath
        
        //shape.fillColor = UIColor.black.withAlphaComponent(0.1).cgColor
        shape.fillRule = .evenOdd
        
        mapOutsideView.layer.mask = shape
        //mapOutsideView.clipsToBounds = true
        mapOutsideView.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        
        
        mapView.addCircle(circle)
        
        mapView.fitArea(toShow: circle)
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters

        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func drawSeed(point: MTMapPoint) {
        let seed = MTMapPOIItem()
        seed.mapPoint = point
        seed.markerType = .customImage
        seed.customImage = UIImage(named: "seed")!
        
        mapView.add(seed)
        
        //latitude: 37.42447813219592, longitude: 126.74313983219017
        let current = CLLocation(latitude: currentCenterLocation.latitude, longitude: currentCenterLocation.longitude)
        let radius = CLLocation(latitude: 37.42447813219592, longitude: 126.74316126511499)
        print("😡 \(current.distance(from: radius))")
        
        
        
        //let converted = locationWithBearing(bearing: Double.pi/2, distanceMeters: 50/2, origin: currentCenterLocation)
        let converted = currentCenterLocation.shift(byDistance: 25, azimuth: Double.pi/2)
        let seed2 = MTMapPOIItem()
        seed2.mapPoint = MTMapPoint(geoCoord: .init(latitude: converted.latitude, longitude: converted.longitude))
        
        seed2.markerType = .customImage
        seed2.customImage = UIImage(named: "seed")!
        
        mapView.add(seed2)
    }
    func setupMapCenter() {
        //let centerCoor = MTMapPoint(geoCoord: .init(latitude: currentCenter.latitude, longitude: currentCenter.longitude))
        mapView.setMapCenter(currentCenter, animated: false)
    }
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.close()
    }
    @IBAction func didTapInsideRegionButton(_ sender: UIButton) {
        drawCircle(center: currentCenter, radius: 10)
    }
    @IBAction func didTapOutsideRegionButton(_ sender: UIButton) {
        
    }
    @IBAction func didTapEditMapButton(_ sender: UIButton) {
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.presentationController?.delegate = self
        setupViews()
        setupMapView()
        setupMapCenter()
        drawCircle(center: currentCenter, radius: 50)
        drawSeed(point: currentCenter)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setupViews() {
        titleTextField.tintColor = .orange
        titleTextField.addLine(position: .bottom, color: .lightGray, width: 0.5)
    }
    
    func setupMapView() {
        
        mapView = MTMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        if let mapView = mapView {
            mapView.delegate = self
            mapView.baseMapType = .standard
            mapBackgroundView.insertSubview(mapView, at: 0)
            
            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: mapBackgroundView.topAnchor, constant: 0),
                mapView.leadingAnchor.constraint(equalTo: mapBackgroundView.leadingAnchor, constant: 0),
                mapView.bottomAnchor.constraint(equalTo: mapBackgroundView.bottomAnchor, constant: 0),
                mapView.trailingAnchor.constraint(equalTo: mapBackgroundView.trailingAnchor, constant: 0)
            ])
        }
    }
    
    func bindViewModel() {
        
    }
    
    // MARK: - Views
    @IBOutlet var mapBackgroundView: UIView!
    var mapView: MTMapView!
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var mapOutsideView: UIView!
    @IBOutlet var titleTextField: UITextField!
    
    
}

extension AddViewController: UIAdaptivePresentationControllerDelegate {
    // MARK: UIAdaptivePresentationControllerDelegate
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.viewModel.close()
    }
}

extension AddViewController: MTMapViewDelegate {
    //MARK: MTMapViewDelegate
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        print(mapPoint.mapPointGeo())
    }
}

extension AddViewController: UITableViewDataSource {
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InputItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addDetailItemCell", for: indexPath) as? AddItemTableViewCell else {return UITableViewCell()}
        
        let item = InputItem.allCases[indexPath.row]
        cell.item = item
        
        return cell
    }
}

extension AddViewController: UITableViewDelegate {
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = InputItem.allCases[indexPath.row]
        switch item {
        case .tag: ""
            // transition tag set VC
        case .endDate: ""
            // show datePicker
        case .alramMsg: ""
            // turn textField
        
        }
    }
}

extension CLLocationCoordinate2D {

    /// Get coordinate moved from current to `distanceMeters` meters with azimuth `azimuth` [0, Double.pi)
    ///
    /// - Parameters:
    ///   - distanceMeters: the distance in meters
    ///   - azimuth: the azimuth (bearing)
    /// - Returns: new coordinate
    func shift(byDistance distanceMeters: Double, azimuth: Double) -> CLLocationCoordinate2D {
        let bearing = azimuth
        let origin = self
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters

        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
