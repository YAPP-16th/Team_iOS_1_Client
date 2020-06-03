//
//  SceneCoordinator.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

class SceneCoordinator: NSObject, SceneCoordinatorType {

    var disposeBag = DisposeBag()
    var window: UIWindow
    var currentVC: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        self.currentVC = window.rootViewController!
    }
    
    // MARK: - Methods
    
    @discardableResult
    func transition(to scene: Scene, using style: Transition, animated: Bool) -> Completable {
        
        let subject = PublishSubject<Void>()
        var target: UIViewController
        target = scene.target
        
//        print("✅ will transition, currentVC: \(currentVC)")
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            currentVC.tabBarController?.delegate = self
            subject.onCompleted()
            
        case .push:
            guard let nav = currentVC.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            nav.rx.willShow
                .subscribe(onNext: {[unowned self] event in
                    self.currentVC = event.viewController.sceneViewController
                })
                .disposed(by: disposeBag)
            
            nav.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
            
        case .modal:
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
            
        case .fullScreen:
            target.modalPresentationStyle = .fullScreen
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
        }
        
//        print("✅ did transition, currentVC: \(currentVC)")
        return subject.ignoreElements()
    }
    
    @discardableResult
	func close(animated: Bool, completion: (() -> Void)? = nil) -> Completable {
        let subject = PublishSubject<Void>()

//        print("✅ will close, currentVC: \(currentVC)")
        
        if let presentingVC = currentVC.presentingViewController {
            currentVC.dismiss(animated: animated) {
                self.currentVC = presentingVC.sceneViewController
//                print("✅ did close, currentVC: \(self.currentVC)")
				completion?()
                subject.onCompleted()
            }
        } else if let nav = currentVC.navigationController {
            guard nav.popViewController(animated: animated) != nil else {
                subject.onError(TransitionError.cannotPop)
                return subject.ignoreElements()
            }

            currentVC = nav.viewControllers.last!
			completion?()
//            print("✅ did close, currentVC: \(self.currentVC)")
            subject.onCompleted()
        } else {
            subject.onError(TransitionError.unknown)
        }
		
        return subject.ignoreElements()
    }
    
    @discardableResult
    func pop(animated: Bool, completion: (() -> Void)? = nil) -> Completable {
        let subject = PublishSubject<Void>()
        
        //print("✅ will pop, currentVC: \(currentVC)")
        
        if let nav = currentVC.navigationController {
            guard nav.popViewController(animated: animated, completion: {completion?()}) != nil else {
                subject.onError(TransitionError.cannotPop)
                return subject.ignoreElements()
            }

            currentVC = nav.viewControllers.last!
            subject.onCompleted()
        }
        //print("✅ did pop, currentVC: \(currentVC)")
        return subject.ignoreElements()
    }
    
    @discardableResult
    func createTabBar() -> Completable {
        
        let mapViewModel = MapViewModel(sceneCoordinator: self)
        let gotListViewModel = GotListViewModel(sceneCoordinator: self)
        let alarmViewModel = AlarmViewModel(sceneCoordinator: self)
        let settingViewModel = SettingViewModel(sceneCoordinator: self)
        
        let mapTab = Tab.map(viewModel: mapViewModel)
        let listTab = Tab.list(viewModel: gotListViewModel)
        let alarmTab = Tab.alarm(viewModel: alarmViewModel)
        let settingTab = Tab.setting(viewModel: settingViewModel)
        
        Tab.tabs.append(contentsOf: [mapTab, listTab, alarmTab, settingTab])
        
        return Completable.empty()
    }
    
    // MARK: - Helpers
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        var controller = viewController
        if let tabBarController = controller as? UITabBarController {
            guard let selectedViewController = tabBarController.selectedViewController else {
                return tabBarController
            }
            controller = selectedViewController
            
            return actualViewController(for: controller)
        }

        if let navigationController = viewController as? UINavigationController {
            controller = navigationController.viewControllers.first!
            
            return actualViewController(for: controller)
        }
        return controller
    }
}

extension UIViewController {
    var sceneViewController: UIViewController {
        
        if let tabBarController = self as? UITabBarController {
            let index = tabBarController.selectedIndex
            if let currentVC = tabBarController.viewControllers?[index] {
                return currentVC.children.first ?? currentVC
            }
        }else if let pageViewController = self as? UIPageViewController{
            return pageViewController
        }
        
        return self.children.first ?? self
    }
    
}

extension SceneCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        currentVC = SceneCoordinator.actualViewController(for: viewController)
        //print("✅ did change tab, currentVC: \(currentVC)")
    }
}
