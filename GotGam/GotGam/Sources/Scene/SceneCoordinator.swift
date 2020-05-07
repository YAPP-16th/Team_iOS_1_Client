//
//  SceneCoordinator.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
}

class SceneCoordinator: NSObject, SceneCoordinatorType {
    
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
    
    var disposeBag = DisposeBag()
    
    var window: UIWindow
    var currentVC: UIViewController {
        didSet {
            currentVC.tabBarController?.delegate = self
        }
    }
    
    required init(window: UIWindow) {
        self.window = window
        self.currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: Transition, animated: Bool) -> Completable {
        
        let subject = PublishSubject<Void>()
        var target: UIViewController
        
        switch scene{
        case .map:
            target = scene.instantiate(from: "Map")
        case .list:
            target = scene.instantiate(from: "List")
        case .add:
            target = scene.instantiate(from: "Map")
        case .setTag:
            target = scene.instantiate(from: "Map")
        case .createTag:
            target = scene.instantiate(from: "Map")
        case .tabBar:
            target = scene.instantiate(from: "Main")
        }
        
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
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
        
        return subject.ignoreElements()
    }
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()

        if let presentingVC = currentVC.presentingViewController {
            currentVC.dismiss(animated: animated) {
                self.currentVC = presentingVC.sceneViewController
                subject.onCompleted()
            }
        } else if let nav = currentVC.navigationController {
            guard nav.popViewController(animated: animated) != nil else {
                subject.onError(TransitionError.cannotPop)
                return subject.ignoreElements()
            }

            currentVC = nav.viewControllers.last!
            subject.onCompleted()
        } else {
            subject.onError(TransitionError.unknown)
        }

        return subject.ignoreElements()
    }
    
    @discardableResult
    func createTabBar(gotService: GotStorageType) -> Completable {
        
        let mapViewModel = MapViewModel(sceneCoordinator: self, storage: gotService)
        let gotListViewModel = GotListViewModel(sceneCoordinator: self, storage: gotService)
        
        let mapTab = Tab.map(viewModel: mapViewModel)
        let listTab = Tab.list(viewModel: gotListViewModel)
        
        Tab.tabs.append(contentsOf: [mapTab, listTab])
        
        return Completable.empty()
    }
    
}

extension SceneCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        currentVC = SceneCoordinator.actualViewController(for: viewController)
    }
}
