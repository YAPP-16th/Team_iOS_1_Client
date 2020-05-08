//
//  TabBarController.swift
//  GotGam
//
//  Created by woong on 18/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift

class TabBarController: UITabBarController, ViewModelBindableType {
    
    var viewModel: TabBarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .orange
        if let items = tabBar.items {
            items[2].image = UIImage(named: "tab_setting")?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: "tab_setting_active")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    func bindViewModel() {
        
//        rx.didSelect
//            .map { [weak self] in
//                (self?.viewControllers?.firstIndex(of: $0) ?? 0)
//            }
//            .subscribe(onNext: { [weak self] tabIndx in
//                self?.viewModel.switchTab(to: tabIndx)
//            })
//            .disposed(by: DisposeBag())
    
    }
    
}

