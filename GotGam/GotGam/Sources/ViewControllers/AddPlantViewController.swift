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
    
    func showAlert(_ label: UILabel, message msg: String) {
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 2.5
        animation.fromValue = 1
        animation.toValue = 0
        animation.isRemovedOnCompletion = true

        label.text = msg
        label.layer.add(animation, forKey: "opacity")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        alertDefaultLabel.layer.cornerRadius = 6
        alertDefaultLabel.alpha = 0
        
        alertErrorLabel.layer.cornerRadius = 6
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
        
        // Input
        
        cancelButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .bind(to: viewModel.close)
            .disposed(by: disposeBag)
        
        titleTextField.text = viewModel.inputs.nameText.value
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        inputTableView.rx.itemSelected
            .filter { $0.section == 0 }
            .subscribe(onNext: { _ in self.viewModel.tapTag.onNext(()) })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.inputs.isOnArrive, viewModel.inputs.isOnLeave)
            .subscribe(onNext: { [unowned self] arrive, leave in
                
                if !arrive, !leave {
                    self.alertErrorLabel.isHidden = false
                    self.saveButton.isEnabled = false
                    return
                } else {
                    self.alertErrorLabel.isHidden = true
                    self.saveButton.isEnabled = true
                }
                
                var msg = ""
                if arrive, leave {
                    msg = "도착할 때와 떠날 때 알려줍니다"
                } else if arrive {
                    msg = "도착할 때만 알려줍니다"
                } else if leave {
                    msg = "떠날 때만 알려줍니다"
                }
                
                self.showAlert(self.alertDefaultLabel, message: msg)
            })
            .disposed(by: disposeBag)
        
        // Output
        
        let dataSource = AddPlantViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.sectionsSubject
            .bind(to: inputTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Views
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var mapBackgroundView: UIView!
    @IBOutlet var alertDefaultLabel: PaddingLabel!
    @IBOutlet var alertErrorLabel: PaddingLabel!
    var mapView: MTMapView!
    @IBOutlet var addIconButton: UIButton!
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var editButton: UIButton!
}

// MARK: - config Data Sources
extension AddPlantViewController {
    
    static func dataSource(viewModel: AddPlantViewModel) -> RxTableViewSectionedAnimatedDataSource<InputSectionModel> {
        //RxTableViewSectionedReloadDataSource
        return RxTableViewSectionedAnimatedDataSource<InputSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .ToggleableItem(title):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "toggleableCell", for: indexPath) as? ToggleableTableViewCell else { return UITableViewCell()}
                    
                    cell.configure(viewModel: viewModel, title: title)
                    
                    if indexPath.section == 1 {
                        cell.enableSwitch.setOn(viewModel.inputs.isOnDate.value, animated: false)
                        cell.enableSwitch.rx
                            .isOn.changed
                            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                            .bind(to: viewModel.isOnDate)
                            .disposed(by: cell.disposedBag)
                    } else if indexPath.section == 2 {
                        cell.enableSwitch.setOn(viewModel.inputs.isOnArrive.value, animated: false)
                        cell.enableSwitch.rx
                            .isOn.changed
                            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                            .bind(to: viewModel.isOnArrive)
                            .disposed(by: cell.disposedBag)
                    } else if indexPath.section == 3 {
                        cell.enableSwitch.setOn(viewModel.inputs.isOnLeave.value, animated: false)
                        cell.enableSwitch.rx
                            .isOn.changed
                            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                            .bind(to: viewModel.isOnLeave)
                            .disposed(by: cell.disposedBag)
                    }
                    return cell
                    
                case .TagItem(let title):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "inputTagCell", for: indexPath) as? InputTagTableViewCell else { return UITableViewCell() }
                    cell.configure(viewModel: viewModel, title: title)
                    return cell
                    
                case .TextFieldItem(let text, let placeholder, let enabled, let isDate):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
                    cell.configure(viewModel: viewModel, text: text, placeholder: placeholder, enabled: enabled, isDate: isDate)
                    
                    if indexPath.section == 1 {
                        cell.textField.rx.text.orEmpty
                            .bind(to: viewModel.dateText)
                            .disposed(by: cell.disposedBag)
                    } else if indexPath.section == 2 {
                        cell.textField.rx.text.orEmpty
                            .bind(to: viewModel.arriveText)
                            .disposed(by: cell.disposedBag)
                    } else if indexPath.section == 3 {
                        cell.textField.rx.text.orEmpty
                            .bind(to: viewModel.leaveText)
                            .disposed(by: cell.disposedBag)
                    }
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

//extension AddPlantViewController: UIAdaptivePresentationControllerDelegate {
//    // MARK: UIAdaptivePresentationControllerDelegate
//
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        self.viewModel.close()
//    }
//}

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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = tableView.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .clear
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == tableView.numberOfSections-1 {
//            return 44
//        }
        return 0
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
