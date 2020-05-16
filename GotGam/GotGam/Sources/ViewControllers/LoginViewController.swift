//
//  LoginViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/11.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit

class LoginViewController: UIViewController{
  
  lazy var facebookLoginButton: FacebookButton = {
    let b = FacebookButton()
    b.translatesAutoresizingMaskIntoConstraints = false
    return b
  }()
  
  lazy var kakaoLoginButton: UIButton = {
    let b = UIButton(type: .system)
    b.setImage(UIImage(named: "btnKakaoLogin")?.withRenderingMode(.alwaysOriginal), for: .normal)
    b.translatesAutoresizingMaskIntoConstraints = false
    b.imageView?.contentMode = .scaleAspectFit
    return b
  }()ImageView(image: UIImage(named: "btnKakaoLogin"))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    prepareFacebookLoginButton()
    prepareKakaoLoginButton()
    if #available(iOS 13.0, *) {
      prepareSignInApple()
    }

    if let token = AccessToken.current, !token.isExpired { // User is logged in, do work such as go to next view controller.
      print(token)
    }

    // Swift // // Extend the code sample from 6a. Add Facebook Login to Your Code // Add to your viewDidLoad method:

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if #available(iOS 13.0, *) {
      NotificationCenter.default.addObserver(self, selector: #selector(appleIDStateRevoked), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }
  }
  
  @objc func appleIDStateRevoked(){
    if #available(iOS 13.0, *){
      NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
    }
  }
  
  private func prepareKakaoLoginButton(){
    self.view.addSubview(kakaoLoginButton)
    NSLayoutConstraint.activate([
      kakaoLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
      kakaoLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
      kakaoLoginButton.bottomAnchor.constraint(equalTo: self.facebookLoginButton.topAnchor, constant: -8),
      kakaoLoginButton.heightAnchor.constraint(equalToConstant: 45)
    ])
  }
  
  private func prepareFacebookLoginButton(){
    self.view.addSubview(facebookLoginButton)
    
    for ic in facebookLoginButton.constraints{
      if ic.constant == 28{
        ic.isActive = false
        break
      }
    }
    NSLayoutConstraint.activate([
      facebookLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
      facebookLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
      facebookLoginButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
      facebookLoginButton.heightAnchor.constraint(equalToConstant: 45)
    ])
    facebookLoginButton.permissions = ["public_profile", "email"]
  }
  @available(iOS 13.0, *)
  private func prepareSignInApple(){
    let siwaButton = ASAuthorizationAppleIDButton()
    self.view.addSubview(siwaButton)
    siwaButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      siwaButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
      siwaButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
      siwaButton.bottomAnchor.constraint(equalTo: self.kakaoLoginButton.topAnchor, constant: -8),
      siwaButton.heightAnchor.constraint(equalToConstant: 45)
    ])
    
    siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    
    if let userID = UserDefaults.standard.string(forDefines: .userID){
      print("이전에 로그인 한 적 있음")
      ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { (credentialState, error) in
        switch credentialState{
        case .authorized:
          print("여전리 해당 아이디로 로그인한 상태")
        case .revoked:
          print("로그인한 적은 있으나, 현재는 제거됨")
        case .notFound:
          print("로그인한 적 없음")
        default:
          print("알수 없음")
        }
      }
    }
    
  }
  
  
  @available(iOS 13.0, *)
  @objc func appleSignInTapped(){
      let provider = ASAuthorizationAppleIDProvider()
      let request = provider.createRequest()
      request.requestedScopes = [.email, .fullName]
      let authController = ASAuthorizationController(authorizationRequests: [request])
      authController.presentationContextProvider = self
      authController.delegate = self
      authController.performRequests()
  }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding{
  @available(iOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }
}
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate{
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
      print("email: ", email)
      print("givenName: ", givenName)
      print("familyName: ", familyName)
      print("nickName: ", nickName)
      print("identityToken: ", identityToken)
      print("authorizationCode: ", authorizationCode)
      
      
      UserDefaults.standard.set(userID, forDefines: .userID)
    }
  }
}
class FacebookButton: FBLoginButton {

    override func updateConstraints() {
        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
        for contraint in constraints {
            if contraint.firstAttribute == .height, contraint.constant < 45 {
                // deactivate this constraint
                contraint.isActive = false
            }
        }
        super.updateConstraints()
    }

    override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: 45)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let logoSize: CGFloat = 24.0
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (logoSize / 2.0)
        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if isHidden || bounds.isEmpty {
            return .zero
        }

        let imageRect = self.imageRect(forContentRect: contentRect)
        let titleX = imageRect.maxX
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - titleX, height: contentRect.height)
        return titleRect
    }

}
