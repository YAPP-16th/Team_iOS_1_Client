//
//  SettingLoginViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingLoginViewModelInputs {
    func getUserInfo()
    func getProfileImage(url: String)
}

protocol SettingLoginViewModelOutputs {
    var settingLoginMenu: Observable<[String]> { get }
    var userInfo: PublishSubject<User> { get set }
    var profileImage: PublishSubject<UIImage> { get set }
}

protocol SettingLoginViewModelType {
    var inputs: SettingLoginViewModelInputs { get }
    var outputs: SettingLoginViewModelOutputs { get }
}


class SettingLoginViewModel: CommonViewModel, SettingLoginViewModelType, SettingLoginViewModelInputs, SettingLoginViewModelOutputs {
    
    var settingLoginMenu = Observable<[String]>.just(["로그아웃", "계정 탈퇴"])
    var userInfo = PublishSubject<User>()
    var profileImage = PublishSubject<UIImage>()
    
    var inputs: SettingLoginViewModelInputs { return self }
    var outputs: SettingLoginViewModelOutputs { return self }
    var storage: GotStorageType!
    
    init(sceneCoordinator: SceneCoordinatorType, storage: GotStorageType) {
        super.init(sceneCoordinator: sceneCoordinator)
        self.storage = storage
    }
    
    func getUserInfo() {
        guard let email = UserDefaults.standard.string(forDefines: .userID) else { return }
        NetworkAPIManager.shared.getUser(email: email) { [weak self] (user) in
            if let user = user{
                self?.userInfo.onNext(user)
            }
        }
    }
    
    func getProfileImage(url: String) {
        NetworkAPIManager.shared.getProfileImage(url: url) { (image) in
            self.profileImage.onNext(image)
        }
    }
    
}
