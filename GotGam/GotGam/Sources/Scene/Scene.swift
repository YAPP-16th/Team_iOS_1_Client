//
//  Scene.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

enum Scene {
    case map(MapViewModel)
    case list(GotListViewModel)
    case add(AddPlantViewModel)
    case addTag(AddTagViewModel)
    case tabBar(TabBarViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .map(let viewModel):
            guard var mapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as? MapViewController else {
                fatalError()
            }
            
            mapVC.bind(viewModel: viewModel)
            
            return mapVC
            
        case .list(let viewModel):
            guard let listNav = storyboard.instantiateViewController(withIdentifier: "GotListNav") as? UINavigationController else {
                fatalError()
            }
            
            guard var listVC = listNav.viewControllers.first as? GotListViewController else {
                fatalError()
            }
            
            listVC.bind(viewModel: viewModel)
            
            return listNav
            
        case .add(let viewModel):
            guard let addNav = storyboard.instantiateViewController(withIdentifier: "AddNav") as? UINavigationController else {
                fatalError()
            }
            guard var addVC = addNav.viewControllers.first as? AddPlantViewController else {
                fatalError()
            }
            addVC.bind(viewModel: viewModel)
            return addNav
            
        case .addTag(let viewModel):
            guard var addTagVC = storyboard.instantiateViewController(withIdentifier: "AddTag") as? AddTagViewController else {
                fatalError()
            }
            addTagVC.bind(viewModel: viewModel)
            return addTagVC
            
        case .tabBar(let viewModel):
            guard var tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBarController else {
                fatalError()
            }
            
            var tempViewControllers = [UIViewController]()
            Tab.tabs.forEach {
                tempViewControllers.append($0.instantiate())
            }
            
            tabBar.viewControllers = tempViewControllers
            tabBar.bind(viewModel: viewModel)
            
            return tabBar
    
        }
    }
}
