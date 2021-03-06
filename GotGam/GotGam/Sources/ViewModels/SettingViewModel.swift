//
//  SettingViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingViewModelInputs {
    func updateUserInfo()
    func getProfileImage(url: String)
    func showAlarmDetailVC()
	func showOtherDetailVC()
	func showPlaceDetailVC()
	func showLoginDetailVC()
    func syncData()
}

protocol SettingViewModelOutputs {
	var settingMenu: Observable<[String]> { get }
    var userInfo: PublishSubject<UserResponseData?> { get set }
    var profileImage: PublishSubject<UIImage> { get set }
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInputs { get }
    var outputs: SettingViewModelOutputs { get }
}


class SettingViewModel: CommonViewModel, SettingViewModelType, SettingViewModelInputs, SettingViewModelOutputs {
	var userInfo = PublishSubject<UserResponseData?>()
    var profileImage = PublishSubject<UIImage>()
    
    func updateUserInfo() {
        if UserDefaults.standard.bool(forDefines: .isLogined), let userId = UserDefaults.standard.string(forDefines: .userID){
            NetworkAPIManager.shared.getUser(email: userId) { user in
                self.userInfo.onNext(user)
            }
        }else{
            self.userInfo.onNext(nil)
        }
    }
    
    
    func getProfileImage(url: String) {
        if url == "default"{
            return
        }
        NetworkAPIManager.shared.downloadImage(url: url).bind(to: self.profileImage)
            .disposed(by: self.disposeBag)
    }
    
	func showAlarmDetailVC() {
		
		let movesettingalarmVM = SettingAlarmViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .settingAlarm(movesettingalarmVM), using: .push, animated: true)
	}
	
	func showOtherDetailVC() {
		
		let movesettingotherVM = SettingOtherViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .settingOther(movesettingotherVM), using: .push, animated: true)
	}
	
	func showPlaceDetailVC() {
        let movesettingplaceVM = SettingPlaceViewModel(sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .settingPlace(movesettingplaceVM), using: .push, animated: true)
	}
	
	func showLoginDetailVC() {
        if !UserDefaults.standard.bool(forDefines: .isLogined){
            let loginViewModel = LoginViewModel(sceneCoordinator: sceneCoordinator)
            sceneCoordinator.transition(to: .login(loginViewModel), using: .modal, animated: true)
        }else{
            let movesettingloginVM = SettingLoginViewModel(sceneCoordinator: sceneCoordinator)
            sceneCoordinator.transition(to: .settingLogin(movesettingloginVM), using: .push, animated: true)
        }
		
	}
    
    func syncData(){
        if UserDefaults.standard.bool(forDefines: .isLogined){
            NetworkAPIManager.shared.synchronize().subscribe { completable in
                switch completable{
                case .completed:
                    print("동기화 성공")
                case .error(let error):
                    print("동기화 실패, \(error.localizedDescription)")
                }
            }.disposed(by: self.disposeBag)
        }
        
    }
	
	var settingMenu = Observable<[String]>.just(["푸시 알람 설정", "자주 가는 장소 설정", "약관 및 정책"])
	
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }
    
}
