//
//  MapRestoreView.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/12.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class MapRestoreView: UIView{
    @IBOutlet weak var restoreButton: UIButton!
    var contentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        if let cv = Bundle.main.loadNibNamed("MapRestoreView", owner: self, options: nil)?.first as? UIView{
            cv.frame = self.bounds
            self.contentView = cv
            
            self.addSubview(cv)
        }
        
        restoreButton.addTarget(self, action: #selector(restoreButtonTap), for: .touchUpInside)
    }
  
    var restoreAction: (() -> Void)? = { }
    
    @objc func restoreButtonTap(){
        self.restoreAction?()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.applySketchShadow(color: .black, alpha: 0.16, x: 0, y: 3, blur: 6, spread: 0)
        roundCorners(corners: [.topRight, .bottomRight], radius: 24.0)
        restoreButton.layer.cornerRadius = 24.0
        restoreButton.layer.applySketchShadow(color: .black, alpha: 0.16, x: 0, y: 3, blur: 6, spread: 0)
    }
}
