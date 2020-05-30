//
//  TutorialPageViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController, ViewModelBindableType{
    
    var viewModel: TutorialViewModel!
    
    let messages: [String] = [
        "환영합니다! :D",
        "원하는 위치에\n알림을 설정할 수 있어요!",
        "내가 지정한 위치 근처에 가면\n소중한 알림이 옵니다!",
        "친구와 알림을\n공유해보세요!"
    ]
    
    lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        let sb = UIStoryboard(name: "Tutorial", bundle: nil)
        for i in 0..<5{
            let vc = sb.instantiateViewController(withIdentifier: "Tutorial\(i + 1)")
            if let tutorialVC = vc as? TutorialViewController{
                tutorialVC.currentIndex = i
                tutorialVC.message = self.messages[i]
                viewControllers.append(tutorialVC)
            }else if let startVC = vc as? StartViewController{
                viewControllers.append(startVC)
            }
        }
        return viewControllers
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        
    }
    func bindViewModel() {
        
    }
    
}

extension TutorialPageViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentVC = viewController as? TutorialViewController else { return nil }
        if currentVC.currentIndex > 0{
            return orderedViewControllers[currentVC.currentIndex - 1]
        }else{
            return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? TutorialViewController else { return nil }
        if currentVC.currentIndex < 4{
            return orderedViewControllers[currentVC.currentIndex + 1]
        }else{
            return nil
        }
        
    }
}
