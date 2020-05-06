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
import CoreLocation
class MapViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    var mapView: MTMapView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var seedButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var quickAddView: MapQuickAddView!
    @IBOutlet weak var seedImageView: UIImageView!
    @IBOutlet weak var restoreView: MapRestoreView!
  
    // MARK: - Constraints
    @IBOutlet weak var cardCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickAddViewBottomConstraint: NSLayoutConstraint!
    
    
    var centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    var poiItem1: MTMapPOIItem!
    
    var state: MapViewModel.SeedState = .none
    
    var gotList: [Got] = []{
        didSet{
            DispatchQueue.main.async {
                self.cardCollectionViewHeightConstraint.constant = self.gotList.isEmpty ? 0 : 170
                self.view.layoutIfNeeded()
                self.cardCollectionView.reloadData()
                self.addPin()
            }
        }
    }
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        
        configureCardCollectionView()
        
        self.quickAddView.isHidden = true
        self.seedImageView.isHidden = true
        self.restoreView.isHidden = true
        
        self.quickAddView.addAction = { [weak self] text in
            guard let self = self else { return }
            
            let centerPoint = self.mapView.mapCenterPoint.mapPointGeo()
            let gotToCreate = Got(title: text!, createdDate: Date(), dueDate: Date.init(timeIntervalSinceNow: 60 * 60 * 24), memo: "", tag: "", location: CLLocationCoordinate2D(latitude: centerPoint.latitude, longitude: centerPoint.longitude), address: "서울특별시")
            self.viewModel.createGot(got: gotToCreate)
            //ToDo: - deliver centerPoint To moedl to create new task
            self.quickAddView.addField.resignFirstResponder()
            self.viewModel.seedState.onNext(.none)
            self.cardCollectionView.isHidden = false
            self.view.layoutIfNeeded()
        }
        self.viewModel.updateList()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
      mapView = MTMapView.init(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
      self.view.sendSubviewToBack(mapView)
    }
    
    private func configureCardCollectionView(){
        cardCollectionView.collectionViewLayout = centeredCollectionViewFlowLayout
        cardCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        centeredCollectionViewFlowLayout.itemSize = CGSize (width: 195, height: 158)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 10
    }
    
    func bindViewModel() {
        viewModel.seedState.subscribe(onNext:{ [weak self] state in
            guard let self = self else { return }
            self.state = state
            switch state{
            case .none:
                self.setNormalStateUI()
            case .seeding:
                self.setSeedingStateUI()
            case .adding:
                self.setAddingStateUI()
            }
            }).disposed(by: disposeBag)
        
        self.seedButton.rx.tap.subscribe(onNext: { [weak self] in
            print("버튼 클릭됨")
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
        
        self.viewModel.gotList.subscribe(onNext: { list in
            self.gotList = list
        }).disposed(by: self.disposeBag)
    }
    
    //MARK: Set UI According to the State
    func setNormalStateUI(){
        self.mapView.removeAllCircles()
        self.seedButton.backgroundColor = .white
        self.seedButton.isEnabled = true
        self.quickAddView.isHidden = true
        self.seedImageView.isHidden = true
    }
    
    func setSeedingStateUI(){
        setCircle(point: mapView.mapCenterPoint)
        self.seedButton.backgroundColor = .saffron
        self.seedButton.setImage(UIImage(named: "icMapBtnSeeding"), for: .normal)
        self.seedButton.isEnabled = true
        self.seedImageView.isHidden = false
    }
    
    func setAddingStateUI(){
        self.seedButton.isEnabled = false
        self.quickAddView.isHidden = false
        self.seedImageView.isHidden = false
        self.seedButton.backgroundColor = .white
        self.seedButton.setImage(UIImage(named: "icMapBtnAdd"), for: .normal
        )
        self.quickAddView.addField.becomeFirstResponder()
    }
    
    func setRestoreViewUI(){
        
    }
    
    func addPin(){
        mapView.removeAllPOIItems()
        for got in gotList{
            let pin = MTMapPOIItem()
            pin.itemName = got.title
            pin.markerType = .customImage
            pin.customImage = UIImage(named: "icPin1")
            pin.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: got.location.latitude, longitude: got.location.longitude))
            pin.showAnimationType = .springFromGround
            mapView.addPOIItems([pin])
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
    
    func setCircle(point: MTMapPoint){
        mapView.removeAllCircles()
        let circle = MTMapCircle()
        circle.circleCenterPoint = point
        circle.circleLineColor = .saffron
      circle.circleLineWidth = 2.0
        circle.circleFillColor = UIColor.saffron.withAlphaComponent(0.17)
        circle.tag = 1234
        circle.circleRadius = 100
      mapView.addCircle(circle)
    }
}

extension MapViewController: MTMapViewDelegate{
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        if self.quickAddView.addField.isFirstResponder{
            self.quickAddView.addField.resignFirstResponder()
        }
    }
    func mapView(_ mapView: MTMapView!, centerPointMovedTo mapCenterPoint: MTMapPoint!) {
        switch self.state{
        case .adding, .seeding:
            setCircle(point: mapCenterPoint)
        case .none:
            break
        }
    }
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        switch self.state{
        case .adding, .seeding:
            setCircle(point: mapCenterPoint)
            break
        case .none:
            break
        }
    }
}



extension MapViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.tagCollectionView{
            return viewModel.tag.count
        }else {
            return self.gotList.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.tagCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapTagCell.reuseIdenfier, for: indexPath) as! MapTagCell
            let data = viewModel.tag[indexPath.item]
            cell.tagIndicator.backgroundColor = .green
            cell.tagLabel.text = data
            return cell
        }else if collectionView == self.cardCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapCardCollectionViewCell.reuseIdenfier, for: indexPath) as! MapCardCollectionViewCell
            let got = self.gotList[indexPath.item]
            cell.got = got
            
            cell.doneButton.rx.tap
            .do(onNext: {
                cell.isDoneFlag = !cell.isDoneFlag
            })
            .debounce(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                cell.got?.isFinished = cell.isDoneFlag
                self.viewModel.updateGot(got: cell.got!)
            }).disposed(by: cell.disposeBag)
            
            cell.cancelButton.rx.tap.subscribe(onNext: {
                self.viewModel.deleteGot(got: cell.got!)
            }).disposed(by: cell.disposeBag)
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
