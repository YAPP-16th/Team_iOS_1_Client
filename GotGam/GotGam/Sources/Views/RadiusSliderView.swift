//
//  RadiusSliderView.swift
//  GotGam
//
//  Created by woong on 2020/06/01.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class RadiusSliderView: UIView {

    
    // MARK: - Properties
    
    var contentView: UIView!
    
    // MARK: - Methods
    
    @objc func updateMeter(slider: UISlider) {
        meterLabel.text = "\(Int(slider.value * 1000))m"
    }
    
    func setRadius(value: Float) {
        radiusSlider.value = value
        meterLabel.text = "\(Int(value * 1000))m"
    }
    
    // MARK: - Initializing
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let cv = Bundle.main.loadNibNamed("RadiusSliderView", owner: self, options: nil)?.first as? UIView{
            cv.frame = self.bounds
            self.contentView = cv
            
            self.addSubview(cv)
        }
        
        radiusSlider.addTarget(self, action: #selector(updateMeter(slider:)), for: .valueChanged)
        
    }
    
    // MARK: - Views
   
    @IBOutlet var radiusSlider: UISlider! {
        didSet{
            radiusSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
    }
    @IBOutlet var meterLabel: UILabel!
    
}
