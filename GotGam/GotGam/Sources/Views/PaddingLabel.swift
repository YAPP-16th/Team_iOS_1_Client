//
//  PaddingLabel.swift
//  GotGam
//
//  Created by woong on 13/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {

    @IBInspectable var padding: UIEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        let paddingRect = rect.inset(by: padding)
        super.drawText(in: paddingRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }

}
