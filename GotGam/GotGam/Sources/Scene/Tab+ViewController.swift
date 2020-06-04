//
//  Tab+ViewController.swift
//  GotGam
//
//  Created by woong on 19/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

extension Tab {
    
    func instantiate() -> UIViewController {
        switch self {
        case .map(let viewModel):
            let storyboard = UIStoryboard(name: "Map", bundle: nil)
            guard let mapNav = storyboard.instantiateViewController(withIdentifier: "MapNav") as? UINavigationController else {
                fatalError()
            }
            guard var mapVC = mapNav.viewControllers.first as? MapViewController else {
                fatalError()
            }
            mapVC.bind(viewModel: viewModel)
            return mapNav
        case .list(let viewModel):
            let storyboard = UIStoryboard(name: "List", bundle: nil)
            guard let listNav = storyboard.instantiateViewController(withIdentifier: "GotListNav") as? UINavigationController else {
                fatalError()
            }
            guard var listVC = listNav.viewControllers.first as? GotListViewController else {
                fatalError()
            }
            listVC.bind(viewModel: viewModel)
            return listNav
        case .alarm(let viewModel):
            let storyboard = UIStoryboard(name: "Alarm", bundle: nil)
            guard let alarmNav = storyboard.instantiateViewController(withIdentifier: "AlarmNav") as? UINavigationController else {
                fatalError()
            }
            guard var alarmVC = alarmNav.viewControllers.first as? AlarmViewController else {
                fatalError()
            }
            alarmVC.bind(viewModel: viewModel)
            return alarmNav
        case .setting(let viewModel):
            let storyboard = UIStoryboard(name: "Setting", bundle: nil)
            guard let settingNav = storyboard.instantiateViewController(withIdentifier: "SettingNav") as? UINavigationController else {
                fatalError()
            }
            guard var settingVC = settingNav.viewControllers.first as? SettingViewController else {
                fatalError()
            }
            settingVC.bind(viewModel: viewModel)
            return settingNav
            
        }
    }
}

