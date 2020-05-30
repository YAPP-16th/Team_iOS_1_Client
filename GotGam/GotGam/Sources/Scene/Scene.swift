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
    case gotBox(GotBoxViewModel)
    case shareList(ShareListViewModel)
    case add(AddPlantViewModel)
    case setTag(SetTagViewModel)
    case createTag(CreateTagViewModel)
    case login(LoginViewModel)
    case tabBar(TabBarViewModel)
	case settingAlarm(SettingAlarmViewModel)
	case settingOther(SettingOtherViewModel)
	case settingPlace(SettingPlaceViewModel)
	case settingLogin(SettingLoginViewModel)
	case searchBar(SearchBarViewModel)
	case frequents(FrequentsViewModel)
	case frequentsSearch(FrequentsSearchViewModel)
	case frequentsMap(FrequentsMapViewModel)
	case settingDetail(SettingOtherDetailViewModel)
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
            
        case .gotBox(let viewModel):
            guard var gotBoxVC = storyboard.instantiateViewController(withIdentifier: "GotBoxVC") as? GotBoxViewController else {
                fatalError()
            }
            gotBoxVC.bind(viewModel: viewModel)
            return gotBoxVC
            
        case .shareList(let viewModel):
            guard var shareListVC = storyboard.instantiateViewController(withIdentifier: "ShareListVC") as? ShareListViewController else {
                fatalError()
            }
            shareListVC.bind(viewModel: viewModel)
            return shareListVC
            
        case .add(let viewModel):
            guard let addNav = storyboard.instantiateViewController(withIdentifier: "AddNav") as? UINavigationController else {
                fatalError()
            }
            guard var addVC = addNav.viewControllers.first as? AddPlantViewController else {
                fatalError()
            }
            addVC.bind(viewModel: viewModel)
            return addNav
            
        case .setTag(let viewModel):
            guard var addTagVC = storyboard.instantiateViewController(withIdentifier: "AddTag") as? SetTagViewController else {
                fatalError()
            }
            addTagVC.bind(viewModel: viewModel)
            return addTagVC
            
        case .createTag(let viewModel):
            guard var createTagVC = storyboard.instantiateViewController(withIdentifier: "CreateTag") as? CreateTagViewController else {
                fatalError()
            }
            createTagVC.bind(viewModel: viewModel)
            return createTagVC
            
        case .login(let viewModel):
            var loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.bind(viewModel: viewModel)
            return loginVC
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
			
		case .settingAlarm(let viewModel):
			guard var settingAlarmVC = storyboard.instantiateViewController(withIdentifier: "SettingAlarm") as? SettingAlarmViewController else {
				fatalError()
			}
		
			settingAlarmVC.bind(viewModel: viewModel)
			return settingAlarmVC
			
			
		case .settingOther(let viewModel):
			guard var settingOtherVC = storyboard.instantiateViewController(withIdentifier: "settingOther") as? SettingOtherViewController else {
				fatalError()
			}
			
			settingOtherVC.bind(viewModel: viewModel)
			return settingOtherVC
			
		case .settingPlace(let viewModel):
			guard var settingPlaceVC = storyboard.instantiateViewController(withIdentifier: "settingPlace") as? SettingPlaceViewController else {
				fatalError()
			}
			
			settingPlaceVC.bind(viewModel: viewModel)
			return settingPlaceVC

		case .settingLogin(let viewModel):
			guard var settingLoginVC = storyboard.instantiateViewController(withIdentifier: "settingLogin") as? SettingLoginViewController else {
				fatalError()
			}
			
			settingLoginVC.bind(viewModel: viewModel)
			return settingLoginVC
			
		case .searchBar(let viewModel):
			guard var searchVC = storyboard.instantiateViewController(withIdentifier: "SearchBarViewController") as? SearchBarViewController else {
				fatalError()
			}
			
			searchVC.bind(viewModel: viewModel)
			return searchVC
			
		case .frequents(let viewModel):
			guard var frequentsVC = storyboard.instantiateViewController(withIdentifier: "FrequentsViewController") as? FrequentsViewController else {
				fatalError()
			}
			
			frequentsVC.bind(viewModel: viewModel)
			return frequentsVC
			
		case .frequentsSearch(let viewModel):
			guard var frequentsSearchVC = storyboard.instantiateViewController(withIdentifier: "FrequentsSearchViewController") as? FrequentsSearchViewController else {
				fatalError()
			}
			
			frequentsSearchVC.bind(viewModel: viewModel)
			return frequentsSearchVC
			
		case .frequentsMap(let viewModel):
			guard var frequentsMapVC = storyboard.instantiateViewController(withIdentifier: "FrequentsMapViewController") as? FrequentsMapViewController else {
				fatalError()
			}
			
			frequentsMapVC.bind(viewModel: viewModel)
			return frequentsMapVC
		
		case .settingDetail(let viewModel):
			guard var settingDetailVC = storyboard.instantiateViewController(withIdentifier: "SettingOtherDetailViewController") as? SettingOtherDetailViewController else {
				fatalError()
			}
			
			settingDetailVC.bind(viewModel: viewModel)
			return settingDetailVC
        }
    }
}
