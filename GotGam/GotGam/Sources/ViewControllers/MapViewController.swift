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
class MapViewController: BaseViewController, ViewModelBindableType, MTMapViewDelegate {
    
    // MARK: - Properties
    
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    @IBOutlet var mapView: MTMapView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    // MARK: - Constraints
    @IBOutlet weak var addButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickAddViewBottomConstraint: NSLayoutConstraint!
    
    
    var centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    var poiItem1: MTMapPOIItem!
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSomePins()
//        setCircle()
        self.button1.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        configureCardCollectionView()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.button1.layer.shadowColor = UIColor.black.cgColor
        self.button1.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.button1.layer.shadowRadius = 5.0
        self.button1.layer.shadowOpacity = 0.3
        self.button1.layer.cornerRadius = 4.0
        self.button1.layer.masksToBounds = false
        
        self.button1.layer.cornerRadius = self.button1.frame.height / 2
        
        self.button2.layer.shadowColor = UIColor.black.cgColor
        self.button2.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.button2.layer.shadowRadius = 5.0
        self.button2.layer.shadowOpacity = 0.3
        self.button2.layer.cornerRadius = 4.0
        self.button2.layer.masksToBounds = false
        
        self.button2.layer.cornerRadius = self.button1.frame.height / 2
        self.button2.backgroundColor = .white
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
//        self.cardCollectionView.isHidden = true
    }
    
    func bindViewModel() {
        
    }
    
    func mapView(_ mapView: MTMapView!, openAPIKeyAuthenticationResultCode resultCode: Int32, resultMessage: String!) {
        print(resultCode)
    }
  
    @objc func addButtonTapped(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func keyboardWillShow(noti: Notification){
        if let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
        if let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
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
