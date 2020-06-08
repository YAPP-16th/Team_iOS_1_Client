//
//  TutorialPageViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
protocol TutorialDelegate{
    func indexChanged(currentIndex: Int)
    func startWithLogin()
    func start()
}

class TutorialPageViewController: UIPageViewController, ViewModelBindableType{
    
    var viewModel: TutorialViewModel!
    var disposeBag = DisposeBag()
    
    var isSkipped: Bool = false
    let messages: [String] = [
        "환영합니다! :D",
        "원하는 위치에\n알림을 설정할 수 있어요!",
        "내가 지정한 위치 근처에 가면\n소중한 알림이 옵니다!",
        "친구와 알림을\n공유해보세요!"
    ]
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 4
        pc.pageIndicatorTintColor = .veryLightPink
        pc.currentPageIndicatorTintColor = .saffron
        return pc
    }()
    
    let skipButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("건너 뛰기", for: .normal)
        b.setTitleColor(.saffron, for: .normal)
        b.layer.cornerRadius = 9
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.saffron.cgColor
        b.layer.masksToBounds = true
        
        return b
    }()
    
    lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        let sb = UIStoryboard(name: "Tutorial", bundle: nil)
        for i in 0..<4{
            let vc = sb.instantiateViewController(withIdentifier: "Tutorial\(i + 1)")
            if let tutorialVC = vc as? TutorialViewController{
                tutorialVC.currentIndex = i
                tutorialVC.message = self.messages[i]
                tutorialVC.delegate = self
                viewControllers.append(tutorialVC)
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
        
        self.view.addSubview(skipButton)
        self.view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            skipButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            skipButton.widthAnchor.constraint(equalToConstant: 128),
            skipButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.skipButton.topAnchor, constant: -44)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSkipped{
            if UserDefaults.standard.bool(forDefines: .isLogined){
                self.viewModel.showMain()
            }else{
                if let startVC = self.storyboard?.instantiateViewController(withIdentifier: "Tutorial5") as? StartViewController{
                    startVC.modalPresentationStyle = .fullScreen
                    self.present(startVC, animated: true) {
                        UserDefaults.standard.set(true, forDefines: .tutorialShown)
                    }
                }
            }
        }
    }
    func bindViewModel() {
        self.skipButton.rx.tap.bind { _ in
            self.isSkipped = true
            self.viewModel.showLoginVC()
        }.disposed(by: self.disposeBag)
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
        if currentVC.currentIndex < 3{
            return orderedViewControllers[currentVC.currentIndex + 1]
        }else{
            return nil
        }
        
    }
}
extension TutorialPageViewController: TutorialDelegate{
    func startWithLogin() {
        self.viewModel.input.showLoginVC()
    }
    
    func start() {
        self.viewModel.input.showMain()
    }
    func indexChanged(currentIndex: Int) {
        
        self.pageControl.currentPage = currentIndex
        if currentIndex == 3{
            self.skipButton.backgroundColor = .saffron
            self.skipButton.setTitleColor(.white, for: .normal)
            self.skipButton.setTitle("시작 하기", for: .normal)
        }else{
            self.skipButton.backgroundColor = .white
            self.skipButton.setTitleColor(.saffron, for: .normal)
            self.skipButton.setTitle("건너 뛰기", for: .normal)
            }
        
    }
}
