//
//  UITextView+centerVertically.swift
//  GotGam
//
//  Created by woong on 18/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
