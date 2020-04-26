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
    
    @IBAction func quickAddAction(){
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let cv = Bundle.main.loadNibNamed("MapQuickAddView", owner: self, options: nil)?.first as? UIView{
            self.contentView = cv
            
            self.addSubview(cv)
        }
    }
    
    
    func bindViewModel(){
        
    }
    
}
