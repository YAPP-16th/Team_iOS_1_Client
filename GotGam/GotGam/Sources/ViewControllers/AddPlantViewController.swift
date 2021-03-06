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
    /// 셀의 섹션 index를 키보드 태그로 한다. 해당하지 않을 경우 -1
    var responseKeyboardTag = -1

    // MARK: - Methods
    
    func drawCircle(center: MTMapPoint, radius: Float) {
        let circle = MTMapCircle()
        circle.circleCenterPoint = center
        circle.circleLineColor = .orange
        circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        circle.circleRadius = radius
        mapView?.addCircle(circle)
    
        mapView?.fitArea(toShow: circle)
    }
    func drawCircle(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: Float) {
        
        let circle = MTMapCircle()
        let center = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        circle.circleCenterPoint = center
        circle.circleLineColor = .orange
        circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        circle.circleRadius = radius
        
        mapView?.addCircle(circle)
        
        mapView?.fitArea(toShow: circle)
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters

        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    func setupMapCenter(latitude: Double, longitude: Double) {
        let centerPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        mapView?.setMapCenter(centerPoint, animated: false)
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

    @objc func keyboardWillShow(_ notification: Notification) {
        guard responseKeyboardTag != -1 else { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardHeight = keyboardFrame.cgRectValue.height
        if inputTableView.frame.height - 50 < keyboardHeight {
            view.frame.origin.y -= keyboardHeight
        } else {
            if responseKeyboardTag >= 0 {
                inputTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.cgRectValue.height, right: 0)
                inputTableView.scrollToRow(at: IndexPath(row: 1, section: responseKeyboardTag), at: .top, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard responseKeyboardTag != -1 else { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else {return}
        
        if inputTableView.frame.height - 50 < keyboardFrame.cgRectValue.height {
            view.frame.origin.y = 0
        } else {
            responseKeyboardTag = -1
            inputTableView.contentInset = .zero
        }
    }
    
    @objc func didTapPlaceLabel(_ sender: Any) {
        if placeLabel.textColor != .black {
            viewModel.inputs.editPlace.onNext(())
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPlaceLabel(_:)))
        textFieldStackView.addGestureRecognizer(tapGesture)
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editButton.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
        editButton.layer.cornerRadius = editButton.frame.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let location = viewModel.placeSubject.value {
            setupMapCenter(latitude: Double(location.latitude), longitude: Double(location.longitude))
            
            
            mapView?.removeAllCircles()
            mapView?.removeAllPOIItems()
            
            let pin = MTMapPOIItem()
            pin.markerType = .customImage
            let seedImage = UIImage(named: "icSeed2")
            pin.customImage = seedImage
            let imageWidth = (seedImage?.size.width ?? 0)
            pin.customImageAnchorPointOffset = .init(offsetX: Int32(imageWidth), offsetY: 0)
            pin.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(location.latitude), longitude: Double(location.longitude)))
            
            mapView?.addPOIItems([pin])

            let radius = viewModel.inputs.radiusSubject.value
            drawCircle(latitude: location.latitude, longitude: location.longitude, radius: Float(radius))
        }
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
        titleTextField.tintColor = .saffron
        titleTextField.addBottomBorderWithColor(color: .gray, width: 0.2)
        alertDefaultLabel.layer.cornerRadius = 6
        alertDefaultLabel.alpha = 0
        alertErrorLabel.layer.cornerRadius = 6
//        print(editButton.frame, editButton.bounds)
//        editButton.layer.cornerRadius = 50
    }
    
    func setupMapView() {
        
        mapView = MTMapView()
        if let mapView = mapView {
            mapView.translatesAutoresizingMaskIntoConstraints = false
            mapView.delegate = self
            mapView.baseMapType = .standard
            mapBackgroundView.insertSubview(mapView, at: 0)
            //mapBackgroundView.addSubview(mapView)
            
            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: mapBackgroundView.topAnchor, constant: 0),
                mapView.leadingAnchor.constraint(equalTo: mapBackgroundView.leadingAnchor, constant: 0),
                mapView.bottomAnchor.constraint(equalTo: mapBackgroundView.bottomAnchor, constant: 0),
                mapView.trailingAnchor.constraint(equalTo: mapBackgroundView.trailingAnchor, constant: 0)
            ])
        }
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func bindViewModel() {
        
        // Output
        
        let dataSource = AddPlantViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.sectionsSubject
            .bind(to: inputTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.outputs.placeSubject
            .compactMap { $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                //self?.saveButton.isEnabled = true
                self?.mapBackgroundZeroHeightConstraint.isActive = false
                self?.mapBackgroundView.isHidden = false
                if self?.mapView == nil {
                    self?.setupMapView()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.inputs.nameText
            .bind(to: titleTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.placeText
            .filter { $0 != "" }
            .subscribe(onNext: { [weak self] place in
                self?.placeLabel.text = place
                self?.placeLabel.textColor = .black
                //self?.setPlaceTextView(text: place)
            })
            .disposed(by: disposeBag)
        
        // Input
        
//        radiusView.setRadius(value: Float(viewModel.inputs.radiusSubject.value/1000))
//        radiusView.radiusSlider.rx.value
//            .map { Double($0) }
//            .bind(to: viewModel.inputs.radiusSubject)
//            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.inputs.placeSubject, viewModel.inputs.radiusSubject)
            .subscribe(onNext: { [weak self] place, radius in
                guard let place = place else { return }
                self?.drawCircle(latitude: place.latitude, longitude: place.longitude, radius: Float(radius))
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.editPlace)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.save)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.close)
            .disposed(by: disposeBag)
        
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        inputTableView.rx.itemSelected
            .filter { $0.section == 0 }
            .subscribe(onNext: { _ in self.viewModel.tapTag.onNext(()) })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.inputs.isOnArrive, viewModel.inputs.isOnLeave, viewModel.outputs.placeSubject, viewModel.inputs.nameText)
            .subscribe(onNext: { [unowned self] arrive, leave, place, title in
                if !arrive, !leave {
                    self.alertErrorLabel.isHidden = false
                    self.saveButton.isEnabled = false
                    return
                } else if place != nil {
                    self.alertErrorLabel.isHidden = true
                    self.saveButton.isEnabled = title.trimmingCharacters(in: .whitespaces).isEmpty ? false : true
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
    }
    
    // MARK: - Views
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    //@IBOutlet var titleTextView: UITextView!
//    @IBOutlet var placeTextView: UITextView!
    @IBOutlet var textFieldStackView: UIStackView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var mapBackgroundView: UIView!
    @IBOutlet var alertDefaultLabel: PaddingLabel!
    @IBOutlet var alertErrorLabel: PaddingLabel!
    var mapView: MTMapView?
    @IBOutlet var addIconButton: UIButton!
    @IBOutlet var inputTableView: UITableView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var mapBackgroundZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mapBackgroundHeightConstraint: NSLayoutConstraint!
}

// MARK: - config Data Sources
extension AddPlantViewController {
    
    static func dataSource(viewModel: AddPlantViewModel, vc: AddPlantViewController) -> RxTableViewSectionedAnimatedDataSource<InputSectionModel> {
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
                            .disposed(by: cell.disposeBag)
                        cell.textField.tag = indexPath.section
                        cell.textField.delegate = vc
                    } else if indexPath.section == 2 {
                        cell.textField.rx.text.orEmpty
                            .bind(to: viewModel.arriveText)
                            .disposed(by: cell.disposeBag)
                        cell.textField.tag = indexPath.section
                        cell.textField.delegate = vc
                    } else if indexPath.section == 3 {
                        cell.textField.rx.text.orEmpty
                            .bind(to: viewModel.leaveText)
                            .disposed(by: cell.disposeBag)
                        cell.textField.tag = indexPath.section
                        cell.textField.delegate = vc
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

//MARK: - MTMapViewDelegate

extension AddPlantViewController: MTMapViewDelegate {
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        print(mapPoint.mapPointGeo())
    }
}

// MARK: - UITableView Delegate

extension AddPlantViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = tableView.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - TextField Delegate
extension AddPlantViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        responseKeyboardTag = textField.tag
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        responseKeyboardTag = -1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
