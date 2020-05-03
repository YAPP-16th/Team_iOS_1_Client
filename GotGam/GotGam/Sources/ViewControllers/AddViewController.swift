//
//  AddViewController.swift
//  GotGam
//
//  Created by woong on 26/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//
import UIKit
import CoreLocation

enum InputItem: Int, CaseIterable {
    case tag = 0
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
        case .endDate:  return "언제까지 가야 할지 알려주세요"
        case .alramMsg: return "알려줄 내용을 적어주세요"
        }
    }
}

extension Hashable where Self : CaseIterable {
    var index: Self.AllCases.Index {
        return type(of: self).allCases.firstIndex(of: self)!
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
        circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        //circle.circleFillColor = .clear
        circle.circleRadius = radius
        
        mapOutsideView.isHidden = true
        
        print(radius, CGFloat(radius))
        //mapOutsideView.backgroundColor = UIColor.b
        
//        let backgroundLayer = CAShapeLayer()
//        let bgPath = UIBezierPath(rect: <#T##CGRect#>)
//
//        let circleLayer = CAShapeLayer()
//        let circlePath = UIBezierPath(rect: mapOutsideView.bounds)
//        circlePath.addArc(withCenter: mapOutsideView.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
//        circleLayer.path = circlePath.cgPath
//
//        circleLayer.fillColor = UIColor.orange.withAlphaComponent(0.1).cgColor
//        circleLayer.fillRule = .evenOdd
//
//        mapView.layer.addSublayer(circleLayer)
//        mapView.addCircle(circle)
        
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
//        let current = CLLocation(latitude: currentCenterLocation.latitude, longitude: currentCenterLocation.longitude)
//        let radius = CLLocation(latitude: 37.42447813219592, longitude: 126.74316126511499)
//        print("😡 \(current.distance(from: radius))")
//
//
//
//        //let converted = locationWithBearing(bearing: Double.pi/2, distanceMeters: 50/2, origin: currentCenterLocation)
//        let converted = currentCenterLocation.shift(byDistance: 25, azimuth: Double.pi/2)
//        let seed2 = MTMapPOIItem()
//        seed2.mapPoint = MTMapPoint(geoCoord: .init(latitude: converted.latitude, longitude: converted.longitude))
//
//        seed2.markerType = .customImage
//        seed2.customImage = UIImage(named: "seed")!
//
//        mapView.add(seed2)
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
    
    @objc func didTapDatePickerDone() {
        view.endEditing(true)
    }
    @objc func didTapDatePickerCancel() {
        guard
            let index: Int = InputItem.allCases.firstIndex(of: .endDate),
            let cell = inputTableView.cellForRow(at: .init(row: index, section: 0)) as? AddItemTableViewCell
            else { return }
        cell.detailTextField.text = ""
        view.endEditing(true)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func setupViews() {
        titleTextField.tintColor = .orange
        titleTextField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        addIconButton.layer.cornerRadius = outsideButton.bounds.height/2
        outsideButton.layer.cornerRadius = outsideButton.bounds.height/2
        insideButton.layer.cornerRadius = insideButton.bounds.height/2
        editButton.layer.cornerRadius = editButton.bounds.height/2
    }
    
    func setupMapView() {
        
        mapView = MTMapView()
        if let mapView = mapView {
            mapView.translatesAutoresizingMaskIntoConstraints = false
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
    @IBOutlet var addIconButton: UIButton!
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var insideButton: UIButton!
    @IBOutlet var outsideButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    @IBOutlet var mapOutsideView: UIView!
    @IBOutlet var titleTextField: UITextField!
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        return datePicker
    }()
    let toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(didTapDatePickerCancel))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(didTapDatePickerDone))
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }()
    
    
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
        
        if item == .endDate {
            cell.datePicker = datePicker
            cell.toolBar = toolBar
        }
        
        cell.item = item
        
        
        
        return cell
    }
}

extension AddViewController: UITableViewDelegate {
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? AddItemTableViewCell else { return }
        
        let item = InputItem.allCases[indexPath.row]
        switch item {
        case .tag: ""
            // transition tag set VC
        case .endDate:
            // show datePicker
            cell.detailTextField.becomeFirstResponder()
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

//	@IBAction func onClickAdd(_ sender: Any) {
//		   if let title = txtTitle.text, let tag = txtLocation.text, let memo = txtMemo.text {
//			   let newMemo = Gotgam(context: DBManager.share.context)
//			   newMemo.title = title
//			   //newMemo.date = date
//			   newMemo.tag = tag
//			   newMemo.content = memo
//			   DBManager.share.saveContext()
//			   //print("성공")
//		   }
//	}
