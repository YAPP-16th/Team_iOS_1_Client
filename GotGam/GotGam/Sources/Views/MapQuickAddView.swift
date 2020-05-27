//
//  MapQuickAddView.swift
//  GotGam
//
//  Created by 손병근 on 2020/04/25.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

struct MapQuickAddViewModel{
    
}

class MapQuickAddView: UIView{
    @IBOutlet weak var addField: UITextField!
    @IBOutlet weak var addButotn: UIButton!
    
    var contentView: UIView!
    var viewModel: MapQuickAddViewModel!
    
    var addAction: ((String?) -> Void)?
    var detailAction: (() -> Void)?
    @IBAction func quickAddAction(){
        if addField.isFirstResponder{
            addField.resignFirstResponder()
        }
        addAction?(self.addField.text)
        addField.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let cv = Bundle.main.loadNibNamed("MapQuickAddView", owner: self, options: nil)?.first as? UIView{
            cv.frame = self.bounds
            self.contentView = cv
            
            self.addSubview(cv)
        }
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(showDetailSeeding))
        gesture.direction = .up
        self.addGestureRecognizer(gesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        addButotn.layer.cornerRadius = addButotn.bounds.size.height / 2
        addButotn.layer.masksToBounds = true
    }
    func bindViewModel(){
        
    }
    
    @objc func showDetailSeeding(){
        if addField.isFirstResponder{
            addField.resignFirstResponder()
            self.isHidden = true
        }
        detailAction?()
    }
}
