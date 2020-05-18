//
//  UIView+line.swift
//  GotGam
//
//  Created by woong on 28/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

extension UIView {
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: self.frame.origin.x,
                              y: self.frame.origin.y+self.frame.height-width, width: self.frame.width, height: width)
        border.backgroundColor = color
        self.superview!.insertSubview(border, aboveSubview: self)
    }
    
    func shadow(radius: CGFloat, color: UIColor, offset: CGSize, opacity: Float) {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
    }
}
