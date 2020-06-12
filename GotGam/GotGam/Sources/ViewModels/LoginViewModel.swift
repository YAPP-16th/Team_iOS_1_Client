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
import AuthenticationServices

protocol LoginViewModelInputs {
    func checkLoginStatus()
    func kakaoLogin()
    func facebookLogin(vc: UIViewController)
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
    
    func facebookLogin(vc: UIViewController) {
        LoginManager().logIn(permissions:  ["public_profile", "email"], from: vc) { (result, error) in
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
    }
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
        NetworkAPIManager.shared.synchronize().subscribe { completable in
            switch completable{
            case .completed:
                self.sceneCoordinator.close(animated: true, completion: nil)
            case .error(let error):
                print("동기화 실패, \(error.localizedDescription)")
            }
        }.disposed(by: self.disposeBag)
        
    }
    
    //MARK: - Helper
    func doLogin(_ type: LoginType){
        switch type {
        case .apple:
            UserDefaults.standard.set("apple", forDefines: .loginType)
        case .facebook:
            UserDefaults.standard.set("facebook", forDefines: .loginType)
        case .google:
            UserDefaults.standard.set("google", forDefines: .loginType)
        case .kakao:
            UserDefaults.standard.set("kakao", forDefines: .loginType)
        }
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
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}
@available(iOS 13.0, *)
extension LoginViewModel: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else { return }
        switch error.code {
        case .canceled:
            print("Canceled")
        case .unknown:
            print("unKnown")
        case .invalidResponse:
            print("invalidResponse")
        case .notHandled:
            print("notHandled")
        case .failed:
            print("failed")
        @unknown default:
            print("default")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let givenName = appleIDCredential.fullName?.givenName
            let familyName = appleIDCredential.fullName?.familyName
            let nickName = appleIDCredential.fullName?.nickname
            
            //서버에 보낼 값
            var identityToken: String?
            if let token = appleIDCredential.identityToken{
                identityToken = String(bytes: token, encoding: .utf8)
            }
            
            var authorizationCode: String?
            if let code = appleIDCredential.authorizationCode{
                authorizationCode = String(bytes: code, encoding: .utf8)
            }
            
            print("userID: ", userID)
            
            if let email = email, let givenName = givenName, let familyName = familyName{
                let loginInfo = SocialLoginInfo(id: userID, email: email, token: familyName + givenName)
                doLogin(.apple(loginInfo))
            }else{
                let loginInfo = SocialLoginInfo(id: userID, email: "", token: "")
                doLogin(.apple(loginInfo))
            }
            UserDefaults.standard.set(userID, forDefines: .userID)
        }
    }
}
