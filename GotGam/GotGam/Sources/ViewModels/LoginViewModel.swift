//
//  LoginViewModel.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/20.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import Moya
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

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
                    
                    self.doLogin(.kakao(info))
                }
            }
        }
    }
    func close(){
        self.sceneCoordinator.close(animated: true, completion: {
//            NetworkAPIManager.shared.SyncAccount()
        })
    }
    
    //MARK: - Helper
    func doLogin(_ type: LoginType){
        let provider = MoyaProvider<GotAPIService>()
        provider.request(.login(type)) { (result) in
            self.processLoginResponse(result: result)
        }
    }
    func processLoginResponse(result: Result<Response, MoyaError>){
        switch result{
        case .success(let response):
            do{
                let jsonDecoder = JSONDecoder()
                let loginResponse = try jsonDecoder.decode(LoginResponse.self
                    , from: response.data)
                let token = loginResponse.user.token
                UserDefaults.standard.set(loginResponse.user.nickname, forDefines: .nickname)
                UserDefaults.standard.set(token, forDefines: .userToken)
                UserDefaults.standard.set(true, forDefines: .isLogined)
                UserDefaults.standard.set(loginResponse.user.userID, forDefines: .userID)
                self.close()
            }catch let error{
                print(error.localizedDescription)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
extension LoginViewModel: LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token else { return }
            let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
            parameters: ["fields": "email, name"],
            tokenString: token.tokenString,
            version: nil,
            httpMethod: .get)
            graphRequest.start { (connection, result, error) -> Void in
                if error == nil {
                    let tokenString = token.tokenString
                    let id = token.userID
                    let email = (result as! [String: Any])["email"] as! String
                    let info = SocialLoginInfo(id: id, email: email, token: tokenString)
                    self.doLogin(.facebook(info))
                }else {
                    print("error \(error)")
                }
            }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("페이스북 로그아웃 완료")
    }
}
