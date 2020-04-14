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

class MapViewController: BaseViewController, ViewModelBindableType, MTMapViewDelegate {
    
    // MARK: - Properties
    
    var viewModel: MapViewModel!
    
    // MARK: - Views
    
    @IBOutlet var mapView: MTMapView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    var poiItem1: MTMapPOIItem!
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        setSomePins()
//        setCircle()
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
//        self.button1.layer.masksToBounds = true
        self.button1.backgroundColor = .white
        
        self.button2.layer.shadowColor = UIColor.black.cgColor
        self.button2.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.button2.layer.shadowRadius = 5.0
        self.button2.layer.shadowOpacity = 0.3
        self.button2.layer.cornerRadius = 4.0
        self.button2.layer.masksToBounds = false
        
        self.button2.layer.cornerRadius = self.button1.frame.height / 2
//        self.button2.layer.masksToBounds = true
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
    
    func bindViewModel() {
        
    }
    
    func mapView(_ mapView: MTMapView!, openAPIKeyAuthenticationResultCode resultCode: Int32, resultMessage: String!) {
        print(resultCode)
    }
}
extension MapViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tag.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapTagCell", for: indexPath) as! MapTagCell
        let data = viewModel.tag[indexPath.item]
        cell.tagIndicator.backgroundColor = .green
        cell.tagLabel.text = data
        return cell
    }
}

extension MapViewController: UICollectionViewDelegate{
    
}

extension MapViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        9 + 14 + 글자 + 16
        let title = viewModel.tag[indexPath.item]
        let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 32), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
        let width = 9 + 14 + 8 + rect.width + 16
        return CGSize(width: width, height: 32)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 11, left: 16, bottom: 10, right: 48)
    }
}

class MapTagCell: UICollectionViewCell{
    @IBOutlet weak var tagIndicator: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.2
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = false
        
        self.contentView.layer.cornerRadius = self.frame.height / 2
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
        self.tagIndicator.layer.cornerRadius = 7
        self.tagIndicator.layer.masksToBounds = true
    }
}
