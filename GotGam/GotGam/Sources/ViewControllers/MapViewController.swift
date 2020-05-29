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
import KakaoLink
class MapViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    var mapView: MTMapView!
    @IBOutlet weak var mapBackgroundView: UIView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var seedButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var quickAddView: MapQuickAddView!
    @IBOutlet weak var seedImageView: UIImageView!
    @IBOutlet weak var restoreView: MapRestoreView!
    @IBOutlet var radiusSlider: UISlider! {
        didSet{
            radiusSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
    }
    @IBOutlet var circleRadiusLabel: UILabel!
    
    // MARK: - Constraints
    @IBOutlet weak var cardCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickAddViewBottomConstraint: NSLayoutConstraint!
    
	@IBAction func moveSearch(_ sender: UITextField) {
		if sender.isFirstResponder{
			sender.resignFirstResponder()
		}
		viewModel.input.showSearchVC()
		
	}
	
    var centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    var poiItem1: MTMapPOIItem!
    
    var state: MapViewModel.SeedState = .none
    
    var gotList: [Got] = []{
        didSet{
            DispatchQueue.main.async {
                self.cardCollectionViewHeightConstraint.constant = self.gotList.isEmpty ? 0 : 170
                self.addPin()
            }
        }
    }
    var currentCircle: MTMapCircle? {
        didSet {
            if let circle = currentCircle {
                let got = gotList[circle.tag]
                print(got.radius)
                radiusSlider.value = Float((got.radius ?? 0)/1000.0)
                circleRadiusLabel.text = "\(Int(radiusSlider.value * 1000))m"
                radiusSlider.isHidden = false
            } else {
                radiusSlider.isHidden = true
            }
        }
    }
	
	//search value
	var x: Double = 0.0
	var y: Double = 0.0
	var addressName: String = ""
	var placeName: String = ""
    
    // MARK: - Methods
    
    func drawCircle(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: Float, tag: Int) {
        let circle = MTMapCircle()
        let center = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        circle.circleCenterPoint = center
        circle.circleLineColor = .orange
        circle.circleFillColor = UIColor.orange.withAlphaComponent(0.1)
        circle.circleRadius = radius
        circle.tag = tag
        currentCircle = circle
        mapView?.addCircle(currentCircle)
    
        mapView?.fitArea(toShow: circle)
    }
    @IBAction func didChangeRadius(_ sender: UISlider) {
        if let tag = currentCircle?.tag, let circle = mapView.findCircle(byTag: tag) {
            let meter = sender.value * 1000
            circle.circleRadius = meter
            mapView.addCircle(circle)
            
            var got = gotList[tag]
            got.radius = Double(meter)
            viewModel.updateGot(got: got)
        }
    }
    
    func appendEmptyTag(_ tags: [Tag]) -> [Tag] {
        var tags = tags
        let emptyTag = Tag(name: "", hex: "empty")
        tags.append(emptyTag)
        return tags
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        
        configureCardCollectionView()
        configureTagCollectionView()
        
        self.quickAddView.isHidden = true
        self.seedImageView.isHidden = true
        self.restoreView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.quickAddView.addAction = { text in
            self.quickAddView.addField.resignFirstResponder()
            self.cardCollectionView.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        self.quickAddView.detailAction = {
//            self.viewModel.input.showAddVC()
//            self.viewModel.seedState.onNext(.none)
            self.linkTest()
        }
        LocationManager.shared.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.viewModel.updateList()
        self.viewModel.updateTagList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let beforeGot = viewModel.beforeGotSubject.value,
            let gotList = try? viewModel.output.gotList.value(),
            let beforeGotIndex = gotList.firstIndex(of: beforeGot) {
            
            setCard(index: beforeGotIndex)
            centeredCollectionViewFlowLayout.scrollToPage(index: beforeGotIndex, animated: true)
        } else if !gotList.isEmpty {
            setCard(index: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        self.seedButton.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
        self.seedButton.layer.cornerRadius = self.seedButton.frame.height / 2
        
        self.myLocationButton.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 2, blur: 10, spread: 0)
        
        self.myLocationButton.layer.cornerRadius = self.seedButton.frame.height / 2
        self.myLocationButton.backgroundColor = .white
    }
    deinit {
        print("map deinit")
    }
    
    
    // MARK: - Initializing
    
    func configureTagCollectionView() {
        tagCollectionView.allowsMultipleSelection = true
        let tagNibName = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagNibName, forCellWithReuseIdentifier: "tagCell")
        let tagListNibName = UINib(nibName: "TagListCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagListNibName, forCellWithReuseIdentifier: "tagListCollectionViewCell")
    }
    
    func configureMapView() {
        mapView = MTMapView.init(frame: mapBackgroundView.bounds)
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapBackgroundView.insertSubview(mapView, at: 0)
        view.sendSubviewToBack(mapBackgroundView)
    }
    
    private func configureCardCollectionView(){
        cardCollectionView.collectionViewLayout = centeredCollectionViewFlowLayout
        cardCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        centeredCollectionViewFlowLayout.itemSize = CGSize (width: 195, height: 158)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 10
    }
    
    func bindViewModel() {
        
        radiusSlider.rx.value
            .map { $0 * 1000 }
            .subscribe(onNext: { [weak self] meter in
                self?.circleRadiusLabel.text = "\(Int(meter))m"
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.aimToPlace, viewModel.seedState)
            .subscribe(onNext:{ [weak self] aimToPlace, state in
            guard let self = self else { return }
            
            switch state{
            case .none:
                self.setNormalStateUI()
            case .seeding:
                self.setSeedingStateUI()
            case .adding:
                if aimToPlace {
                    let centerPoint = self.mapView.mapCenterPoint.mapPointGeo()
                    let location = CLLocationCoordinate2D(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
                    self.viewModel.input.savePlace(location: location)
                    return
                }
                self.setAddingStateUI()
            }
            self.state = state
            }).disposed(by: disposeBag)
//        viewModel.seedState.subscribe(onNext:{ [weak self] state in
//            guard let self = self else { return }
//            self.state = state
//            switch state{
//            case .none:
//                self.setNormalStateUI()
//            case .seeding:
//                self.setSeedingStateUI()
//            case .adding:
//                self.setAddingStateUI()
//            }
//            }).disposed(by: disposeBag)
        
        self.seedButton.rx.tap.subscribe(onNext: { [weak self] in
            print("버튼 클릭됨")
            guard let self = self else { return }
            switch self.state {
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
        
        self.tagCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.cardCollectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        self.viewModel.output.gotList.bind(to: cardCollectionView.rx.items(cellIdentifier: MapCardCollectionViewCell.reuseIdenfier, cellType: MapCardCollectionViewCell.self)) { (index, got, cell) in
            cell.got = got
            
            cell.doneButton.rx.tap
            .subscribe(onNext: {
                guard var got = cell.got else { return }
                self.viewModel.setGotDone(got: got)
            }).disposed(by: cell.disposeBag)
            
            cell.cancelButton.rx.tap.subscribe(onNext: {
                self.viewModel.deleteGot(got: cell.got!)
            }).disposed(by: cell.disposeBag)
        }.disposed(by: self.disposeBag)
        
//        self.viewModel.output.tagList.bind(to: tagCollectionView.rx.items(cellIdentifier: MapTagCell.reuseIdenfier, cellType: MapTagCell.self)) { (index, tag, cell) in
//            cell.tagIndicator.backgroundColor = tag.hex.hexToColor()
//            cell.tagLabel.text = tag.name
//        }.disposed(by: self.disposeBag)
        
        viewModel.output.tagList
        .compactMap { [weak self] in self?.appendEmptyTag($0) }
        .bind(to: tagCollectionView.rx.items) { (collectionView, cellItem, tag) -> UICollectionViewCell in
            if cellItem != collectionView.numberOfItems(inSection: 0)-1 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: IndexPath(item: cellItem, section: 0)) as? TagCollectionViewCell else { return UICollectionViewCell()}
                cell.configure(tag)
                cell.layer.cornerRadius = cell.bounds.height/2
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListCollectionViewCell", for: IndexPath(item: cellItem, section: 0)) as? TagListCollectionViewCell else { return UICollectionViewCell()}
                cell.layer.cornerRadius = cell.bounds.height/2
                return cell
            }
        }
        .disposed(by: disposeBag)
        
        
        self.viewModel.output.gotList.subscribe(onNext: { list in
            self.gotList = list
        }).disposed(by: self.disposeBag)
        
        quickAddView.addButotn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                if let centerPoint = self?.mapView.mapCenterPoint.mapPointGeo() {
                    let location = CLLocationCoordinate2D(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
                    self?.viewModel.input.quickAdd(location: location)
                }
            })
            .disposed(by: disposeBag)
        
        quickAddView.addField.rx.text.orEmpty
            .bind(to: viewModel.input.addText)
            .disposed(by: disposeBag)
        
//        self.quickAddView.addAction = { [weak self] text in
//            guard let self = self else { return }
//
//            let centerPoint = self.mapView.mapCenterPoint.mapPointGeo()
//            let location = CLLocationCoordinate2D(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
//
//            self.viewModel.input.quickAdd(text: text ?? "", location: location)
//        }
        
        self.viewModel.output.doneAction.bind { got in
            self.viewModel.input.updateList()
            self.restoreView.isHidden = false
            self.restoreView.restoreAction = {
                self.restoreView.isHidden = true
                var tmpGot = got
                tmpGot.isDone = false
                self.viewModel.input.updateGot(got: tmpGot)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.restoreView.isHidden = true
            }
        }.disposed(by: self.disposeBag)
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
        for (i, got) in gotList.enumerated() {
            let pin = MTMapPOIItem()
            pin.itemName = got.title
            pin.markerType = .customImage
            pin.customImage = UIImage(named: "icPin1")
            pin.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: got.latitude!, longitude: got.longitude!))
            //pin.showAnimationType = .springFromGround
            pin.tag = i
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
                print("설정으로 이동시키기")
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
    
    func setCard(index: Int) {
        guard let gotList = try? self.viewModel.output.gotList.value() else { return }
        let got = gotList[index]
        if let lat = got.latitude, let long = got.longitude, let radius = got.radius {
            let geo = MTMapPointGeo(latitude: lat, longitude: long)
            self.mapView.setMapCenter(MTMapPoint(geoCoord: geo), animated: true)
            mapView.removeAllCircles()
            drawCircle(latitude: lat, longitude: long, radius: Float(radius), tag: index)
        }
        
    }
	
	func updateAddress() {
		self.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: y, longitude: x)), animated: true)
	}
    
    func linkTest(){
        KakaoLinkManager.shared.shareLink("곳감", "손병근님이 000태그를 보냈습니다\n\n곳감에서000님의 장소를 확인해보세요", thumbnail: "http://k.kakaocdn.net/dn/JoPV3/btqD3IuoYzJ/MeAWwvHSXDx4eZAMfkHfs1/img_640x640.jpg")
    }
}

extension MapViewController: MTMapViewDelegate{
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        if self.quickAddView.addField.isFirstResponder{
            self.quickAddView.addField.resignFirstResponder()
        }
		print(mapPoint.mapPointGeo())
    }
    func mapView(_ mapView: MTMapView!, centerPointMovedTo mapCenterPoint: MTMapPoint!) {
        switch self.state {
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
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        let got = gotList[poiItem.tag]
        if let lat = got.latitude, let long = got.longitude, let radius = got.radius {
            mapView?.removeAllCircles()
            drawCircle(latitude: lat, longitude: long, radius: Float(radius), tag: poiItem.tag)
        }
        
        return true
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.tagCollectionView{
//            guard let tagList = try? self.viewModel.output.tagList.value(), !tagList.isEmpty else { return .zero }
//            let title = tagList[indexPath.item].name
//            let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 32), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
//            let width = 9 + 14 + 8 + rect.width + 16
//            return CGSize(width: width, height: 32)
            
            // 8 + 태그뷰
            var tagWidth: CGFloat = 0
            var title = "태그 목록"
            
            //마지막 셀 = 태그목록
            if indexPath.item != collectionView.numberOfItems(inSection: 0) - 1 {
                tagWidth = 8 + 15
                if let tagList = try? viewModel.output.tagList.value() {
                    title = tagList[indexPath.item].name
                }
//                title = viewModel.output.tagList.value[indexPath.item].name
            }
            
            let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
            
            // tagWidth + 8 + 글자
            let width: CGFloat = tagWidth + 8 + rect.width + 8
            // cell height - inset(10)
            let height: CGFloat = 30
            return CGSize(width: width, height: height)
            
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

extension MapViewController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentIndex = self.centeredCollectionViewFlowLayout.currentCenteredPage else { return }
        setCard(index: currentIndex)
//        guard let gotList = try? self.viewModel.output.gotList.value() else { return }
//        let got = gotList[currentIndex]
//        let geo = MTMapPointGeo(latitude: got.latitude ?? .zero, longitude: got.longitude ?? .zero)
//        self.mapView.setMapCenter(MTMapPoint(geoCoord: geo), animated: true)
    }
}
