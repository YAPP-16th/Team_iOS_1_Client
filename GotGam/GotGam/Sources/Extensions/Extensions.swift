//
//  Extensions.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/26.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

extension CLLocationCoordinate2D {
  
  private static let Lat = "lat"
  private static let Lon = "lon"
  
  typealias CLLocationDictionary = [String: CLLocationDegrees]
  
  var asDictionary: CLLocationDictionary {
    return [CLLocationCoordinate2D.Lat: self.latitude,
            CLLocationCoordinate2D.Lon: self.longitude]
  }
  
  init(dict: CLLocationDictionary) {
    self.init(latitude: dict[CLLocationCoordinate2D.Lat]!,
              longitude: dict[CLLocationCoordinate2D.Lon]!)
  }
  
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
extension CALayer{
  
  
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
