//
//  AddViewController.swift
//  GotGam
//
//  Created by woong on 26/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import CoreLocation

enum InputItemType: CaseIterable {
    static var allCases: [InputItemType] {
        return [.tag(nil), .endDate(nil), .alramMsg(nil) ]
    }
    
    case tag(String?)
    case endDate(Date?)
    case alramMsg(String?)
    
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


class AddPlantViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: AddPlantViewModel!
    var currentCenter: MTMapPoint = MTMapPoint(geoCoord: .init(latitude: 37.42462158203125, longitude: 126.74259919223122))
    var currentCenterLocation = CLLocationCoordinate2D(latitude: 37.42462158203125, longitude: 126.74259919223122)
    let locationManager = CLLocationManager()

    // MARK: - Methods
    
    func drawCircle(center: MTMapPoint, radius: Float) {
        let circle = MTMapCircle()
        circle.circleCenterPoint = center
        circle.circleLineColor = .orange
        circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        circle.circleRadius = radius
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
    }
    func setupMapCenter() {
        //let centerCoor = MTMapPoint(geoCoord: .init(latitude: currentCenter.latitude, longitude: currentCenter.longitude))
        mapView.setMapCenter(currentCenter, animated: false)
    }
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.close()
    }

    @IBAction func didTapEditMapButton(_ sender: UIButton) {
    }
    
    @objc func didTapDatePickerDone() {
        view.endEditing(true)
    }
    @objc func didTapDatePickerCancel() {
//        guard
//            let index: Int = InputItemType.allCases.firstIndex(of: .endDate),
//            let cell = inputTableView.cellForRow(at: .init(row: index, section: 0)) as? AddItemTableViewCell
//            else { return }
//        cell.detailTextField.text = ""
//        view.endEditing(true)
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
    
    // MARK: - Initializing
    
    func setupViews() {
        titleTextField.tintColor = .orange
        titleTextField.addLine(position: .bottom, color: .lightGray, width: 0.5)
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
        
//        viewModel.outputs.initGot?
//            .compactMap { $0.title }
//            .bind(to: titleTextField.rx.text )
//            .disposed(by: disposeBag)
//
        let dataSource = AddPlantViewController.dataSource()
        
        viewModel.outputs.sections
            .bind(to: inputTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        inputTableView.rx.modelSelected(InputItem.self)
            .compactMap{ $0 }
            .subscribe(onNext: { [unowned self] item in
                switch item {
                case let .TagItem(_, tag):
                    self.viewModel.inputs.pushAddTagVC(tag: tag)
                case let .TextFieldItem(text, placeholder, enabled):
                    ""
                case let .ToggleableItem(title, enabled):
                    ""
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Views
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var mapBackgroundView: UIView!
    var mapView: MTMapView!
    @IBOutlet var addIconButton: UIButton!
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var editButton: UIButton!
    
    
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

extension AddPlantViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<InputSectionModel> {
        return RxTableViewSectionedReloadDataSource<InputSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .ToggleableItem(title, enabled):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "toggleableCell", for: indexPath) as? ToggleableTableViewCell else { return UITableViewCell()}
                    cell.configure(title: title, enabled: enabled)
                    return cell
                case .TagItem(let title, let tag):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "inputTagCell", for: indexPath) as? InputTagTableViewCell else { return UITableViewCell() }
                    // TODO: tag 새로만들기
                    cell.configure(title: title, tag: tag)
                    return cell
                case .TextFieldItem(let text, let placeholder, let enabled):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
                    cell.configure(text: text, placeholder: placeholder, enabled: enabled)
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            }
        )
    }
}

extension AddPlantViewController: UIAdaptivePresentationControllerDelegate {
    // MARK: UIAdaptivePresentationControllerDelegate
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.viewModel.close()
    }
}

extension AddPlantViewController: MTMapViewDelegate {
    //MARK: MTMapViewDelegate
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        print(mapPoint.mapPointGeo())
    }
}

extension AddPlantViewController: UITableViewDelegate {
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
