//
//  SettingViewController.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: SettingViewModel!

	
	@IBOutlet var SettingTableView: UITableView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }
    
    func bindViewModel() {
        
    }
}
