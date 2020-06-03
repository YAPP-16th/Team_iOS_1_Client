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
    var disposeBag = DisposeBag()
    
    @objc func updateBadge() {
        viewModel.updateBadge()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNotification()
        
        tabBar.tintColor = .saffron
        if let items = tabBar.items, items.count == 4 {
            items[0].image = UIImage(named: "tab_map")?.withRenderingMode(.alwaysOriginal)
            items[0].selectedImage = UIImage(named: "tab_map_active")?.withRenderingMode(.alwaysOriginal)
            
            items[1].image = UIImage(named: "tab_list")?.withRenderingMode(.alwaysOriginal)
            items[1].selectedImage = UIImage(named: "tab_list_active")?.withRenderingMode(.alwaysOriginal)
            
            items[2].image = UIImage(named: "tab_alarm")?.withRenderingMode(.alwaysOriginal)
            items[2].selectedImage = UIImage(named: "tab_alarm_active")?.withRenderingMode(.alwaysOriginal)
            
            items[3].image = UIImage(named: "tab_setting")?.withRenderingMode(.alwaysOriginal)
            items[3].selectedImage = UIImage(named: "tab_setting_active")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: .onDidUpdateAlarm, object: nil)
    }
    
    func bindViewModel() {
        
        viewModel.alarmBadgeCount
            .subscribe(onNext: { [weak self] count in
                self?.tabBar.items?[2].badgeValue = count == 0 ? nil : "\(count)"
            })
            .disposed(by: disposeBag)
        

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

