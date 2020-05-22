//
//  LoginViewModel.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import Moya

protocol LoginViewModelInputs {
    func checkLoginStatus()
    func kakaoLogin()
}

protocol LoginViewModelOutputs {
    
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

extension LoginViewModelType{
    
}

class LoginViewModel: CommonViewModel, LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs{
    
    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }
    
    //MARK: - Inputs
    func checkLoginStatus() {
        
    }
    //MARK: - Login Helper
    func kakaoLogin(){
        KOSession.shared()?.close()
        KOSession.shared()?.open(completionHandler: { [weak self] (error) in
            
            if let error = error{
                print(error)
            }else{
                print("로그인 성공")
                self?.checkKakaoToken()
            }
            }, parameters: nil, authTypes: [NSNumber(value: KOAuthType.talk.rawValue), NSNumber(value: KOAuthType.account.rawValue)])
    }
    func checkKakaoToken(){
        guard let token = KOSession.shared()?.token else { return }
        
        let accessToken = token.accessToken
        
        KOSessionTask.accessTokenInfoTask { (tokenInfo, error) in
            if error != nil{
                print("예기치 못한 에러, 서버 에러")
            }else{
                KOSessionTask.userMeTask { (error, user) in
                    guard let id = tokenInfo?.id else { return }
                    guard let email = user?.account?.email else { return }
                    let info = SocialLoginInfo(id: id.stringValue, email: email, token: accessToken)
                    
                    let provider = MoyaProvider<GotAPIService>()
                    provider.request(.login(.kakao(info))) { result in
                        switch result{
                        case .success(let response):
                            let data = response.data
                            let decoder = JSONDecoder()
                            do{
                                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                                let token = loginResponse.user.token
                                UserDefaults.standard.set(token, forDefines: .userToken)
                                UserDefaults.standard.set(true, forDefines: .isLogined)
                                self.close()
                            }catch let error{
                                print(error)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
    func close(){
        self.sceneCoordinator.close(animated: true)
    }
}
