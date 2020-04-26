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
import CenteredCollectionView

class MapViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    @IBOutlet var mapView: MTMapView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var seedButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var quickAddView: MapQuickAddView!
    
    // MARK: - Constraints
    @IBOutlet weak var cardCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickAddViewBottomConstraint: NSLayoutConstraint!
    
    
    var centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    var poiItem1: MTMapPOIItem!
    
    var state: MapViewModel.SeedState = .none
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
//        setCircle()
        
        configureCardCollectionView()
        self.quickAddView.isHidden = true
        self.quickAddView.addAction = { text in
            self.quickAddView.addField.resignFirstResponder()
            self.viewModel.seedState.onNext(.none)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.seedButton.layer.shadowColor = UIColor.black.cgColor
        self.seedButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.seedButton.layer.shadowRadius = 5.0
        self.seedButton.layer.shadowOpacity = 0.3
        self.seedButton.layer.cornerRadius = 4.0
        self.seedButton.layer.masksToBounds = false
        
        self.seedButton.layer.cornerRadius = self.seedButton.frame.height / 2
        
        self.myLocationButton.layer.shadowColor = UIColor.black.cgColor
        self.myLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.myLocationButton.layer.shadowRadius = 5.0
        self.myLocationButton.layer.shadowOpacity = 0.3
        self.myLocationButton.layer.cornerRadius = 4.0
        self.myLocationButton.layer.masksToBounds = false
        
        self.myLocationButton.layer.cornerRadius = self.seedButton.frame.height / 2
        self.myLocationButton.backgroundColor = .white
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
    
    private func configureCardCollectionView(){
        cardCollectionView.collectionViewLayout = centeredCollectionViewFlowLayout
        cardCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        centeredCollectionViewFlowLayout.itemSize = CGSize (width: 195, height: 158)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 10
        self.cardCollectionViewHeightConstraint.constant = 0
        self.cardCollectionView.isHidden = true
    }
    
    func bindViewModel() {
        viewModel.seedState.subscribe(onNext:{ [weak self] state in
            guard let self = self else { return }
            self.state = state
            switch state{
            case .none:
                self.seedButton.backgroundColor = .white
                self.seedButton.isEnabled = true
                self.quickAddView.isHidden = true
            case .seeding:
                self.seedButton.backgroundColor = .orange
                self.seedButton.isEnabled = true
            case .adding:
                self.seedButton.isEnabled = false
                self.quickAddView.isHidden = false
                self.quickAddView.addField.becomeFirstResponder()
                break
            }
            }).disposed(by: disposeBag)
        
        self.seedButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            switch self.state{
            case .none:
                self.viewModel.seedState.onNext(.seeding)
            case .seeding:
                self.viewModel.seedState.onNext(.adding)
            case .adding:
                self.viewModel.seedState.onNext(.none)
            }
            
        }).disposed(by: disposeBag)
        self.myLocationButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.setMyLocation()
            }).disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func keyboardWillShow(noti: Notification){
        if let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.quickAddViewBottomConstraint.constant == 0{
                self.quickAddViewBottomConstraint.constant = keyboardSize.height - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
        if let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.quickAddViewBottomConstraint.constant != 0 {
                self.quickAddViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    func setMyLocation(){
        LocationManager.shared.requestAuthorization()
        if LocationManager.shared.locationServicesEnabled {
            let status = LocationManager.shared.authorizationStatus
            switch status{
            case .denied:
              print("거부됨")
            case .notDetermined, .restricted:
                print("성정으로 이동시키기")
            case .authorizedWhenInUse, .authorizedAlways:
                self.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: LocationManager.shared.currentLocation!.latitude, longitude: LocationManager.shared.currentLocation!.longitude)), animated: true)
            }
            
        }else{
        }
    }
}

extension MapViewController: MTMapViewDelegate{
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        if self.quickAddView.addField.isFirstResponder{
            self.quickAddView.addField.resignFirstResponder()
        }
    }
    func mapView(_ mapView: MTMapView!, doubleTapOn mapPoint: MTMapPoint!) {
        if self.quickAddView.addField.isFirstResponder{
            self.quickAddView.addField.resignFirstResponder()
        }
    }
}



extension MapViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tag.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.tagCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapTagCell", for: indexPath) as! MapTagCell
            let data = viewModel.tag[indexPath.item]
            cell.tagIndicator.backgroundColor = .green
            cell.tagLabel.text = data
            return cell
        }else if collectionView == self.cardCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCardCollectionViewCell", for: indexPath) as! MapCardCollectionViewCell
            return cell
        }else{
            fatalError()
        }
    }
}

extension MapViewController: UICollectionViewDelegate{

}

extension MapViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        9 + 14 + 글자 + 16
        if collectionView == self.tagCollectionView{
            let title = viewModel.tag[indexPath.item]
            let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 32), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
            let width = 9 + 14 + 8 + rect.width + 16
            return CGSize(width: width, height: 32)
        }else if collectionView == cardCollectionView{
            return centeredCollectionViewFlowLayout.itemSize
        }else{
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.tagCollectionView{
            return 8
        }else if collectionView == self.cardCollectionView{
            return centeredCollectionViewFlowLayout.minimumLineSpacing
        }else{
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.tagCollectionView{
            return UIEdgeInsets(top: 11, left: 16, bottom: 10, right: 48)
        }else if collectionView == self.cardCollectionView{
            return centeredCollectionViewFlowLayout.sectionInset
        }else{
            fatalError()
        }
    }
}
