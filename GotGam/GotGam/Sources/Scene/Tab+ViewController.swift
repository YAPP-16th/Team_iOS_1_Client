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
            guard var mapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as? MapViewController else {
                fatalError()
            }
            mapVC.bind(viewModel: viewModel)
            return mapVC
            
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
        }
    }
}
