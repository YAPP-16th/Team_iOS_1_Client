//
//  MapRestoreView.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/04.
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
    }
}
