//
//  LoginViewController.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/11.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import AuthenticationServices
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import RxSwift
import RxCocoa

enum LoginType{
    case google(SocialLoginInfo)
    case kakao(SocialLoginInfo)
    case facebook(SocialLoginInfo)
    case apple(SocialLoginInfo)
}

struct SocialLoginInfo{
    var id: String
    var email: String
    var token: String
}

class LoginViewController: UIViewController, ViewModelBindableType{
    
    var viewModel: LoginViewModel!
    var disposeBag = DisposeBag()
    //MARK: Views
    lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icLoginLogo")?.withRenderingMode(.alwaysOriginal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    lazy var cancelLoginButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("로그인 없이 시작하기", for: .normal)
        btn.setTitleColor(.saffron, for: .normal)
        btn.layer.cornerRadius = 9
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.saffron.cgColor
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return btn
    }()
    
    lazy var facebookLoginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "icBtnLoginFacebook")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var kakaoLoginButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .black
        b.setImage(UIImage(named: "icBtnLoginKakao")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        return b
    }()
    
    lazy var googleLoginButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "icBtnLoginGoogle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        prepareLoginButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let accessToken = AccessToken.current{
            print("user is already logged in")
            print(accessToken)
        }
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appleIDStateRevoked), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
    }
    
    @objc func appleIDStateRevoked(){
        if #available(iOS 13.0, *){
            NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
    }
    
    
    
    
    @available(iOS 13.0, *)
    @objc func appleSignInTapped(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self.viewModel
        authController.delegate = self.viewModel
        authController.performRequests()
    }
    @objc func kakaoLoginTapped(){
        self.viewModel.inputs.kakaoLogin()
    }
    @objc private func googleLoginTapped(){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc private func googleLogoutTapped(){
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    @objc func kakaoLogoutTapped(){
        KOSession.shared()?.logoutAndClose(completionHandler: { (success, error) in
            if error != nil {
                print("로그아웃 실패, - error: \(error!.localizedDescription)")
            }else{
                print("로그아웃 상태: \(success ? "성공" : "실패")")
            }
        })
    }
    @objc func cancel(){
        self.viewModel.close()
    }
    
    func bindViewModel() {
        self.facebookLoginButton.rx.tap.bind { _ in
            self.viewModel.inputs.facebookLogin(vc: self)
        }.disposed(by: self.disposeBag)
    }
}

//MARK: - UI
extension LoginViewController{
    private func prepareLoginButtons(){
        prepareLoginImageView()
        prepareCancelLoginButton()
        prepareFacebookLoginButton()
        prepareKakaoLoginButton()
        prepareSignInGoogle()
        if #available(iOS 13.0, *) {
            prepareSignInApple()
        }
    }
    
    private func prepareCancelLoginButton(){
        self.view.addSubview(cancelLoginButton)
        NSLayoutConstraint.activate([
            cancelLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            cancelLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            cancelLoginButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            cancelLoginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    private func prepareLoginImageView(){
        self.view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 120),
            logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    private func prepareKakaoLoginButton(){
        self.view.addSubview(kakaoLoginButton)
        NSLayoutConstraint.activate([
            kakaoLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            kakaoLoginButton.bottomAnchor.constraint(equalTo: self.facebookLoginButton.topAnchor, constant: -8),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 48)
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
            facebookLoginButton.bottomAnchor.constraint(equalTo: self.cancelLoginButton.topAnchor, constant: -8),
            facebookLoginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        
    }
    
    private func prepareSignInGoogle(){
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        self.view.addSubview(googleLoginButton)
        
        NSLayoutConstraint.activate([
            googleLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            googleLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            googleLoginButton.bottomAnchor.constraint(equalTo: self.kakaoLoginButton.topAnchor, constant: -8),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @available(iOS 13.0, *)
    private func prepareSignInApple(){
        let siwaButton = ASAuthorizationAppleIDButton()
        self.view.addSubview(siwaButton)
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            siwaButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            siwaButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            siwaButton.bottomAnchor.constraint(equalTo: self.googleLoginButton.topAnchor, constant: -8),
            siwaButton.heightAnchor.constraint(equalToConstant: 48)
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
}




//class FacebookButton: FBLoginButton {
//
//    override func updateConstraints() {
//        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
//        for contraint in constraints {
//            if contraint.firstAttribute == .height, contraint.constant < 45 {
//                // deactivate this constraint
//                contraint.isActive = false
//            }
//        }
//        super.updateConstraints()
//    }
//
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: 45)
//    }
//
//    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
//        let logoSize: CGFloat = 24.0
//        let centerY = contentRect.midY
//        let y: CGFloat = centerY - (logoSize / 2.0)
//        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
//    }
//
//    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
//        if isHidden || bounds.isEmpty {
//            return .zero
//        }
//
//        let imageRect = self.imageRect(forContentRect: contentRect)
//        let titleX = imageRect.maxX
//        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - titleX, height: contentRect.height)
//        return titleRect
//    }
//
//}

