//
//  KakaoLinkManager.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/24.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class KakaoLinkManager{
    static let shared = KakaoLinkManager()
    
    func shareLink(_ name: String, _ description: String, thumbnail: String){
        let template = KMTFeedTemplate { (builder) in
            builder.content = KMTContentObject(builderBlock: { (contentBuilder) in
                contentBuilder.title = name
                contentBuilder.desc = description
                if let imageUrl = try? thumbnail.asURL() {
                    contentBuilder.imageURL = imageUrl
                }
                contentBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.mobileWebURL = URL(string: "https://developers.kakao.com")
                })
            })
            
            builder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.title = "자세히 보기"
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.iosExecutionParams = "gotgam://test/1"
                    linkBuilder.androidExecutionParams = "gotgam://test/1"
                })
            }))
        }
        let serverCallbackArgs = ["gotId": "1"]
        KLKTalkLinkCenter.shared().sendDefault(with: template, serverCallbackArgs: serverCallbackArgs, success: { (warningMsg, argumentMsg) in
            
            // 성공
            print("warning message: \(String(describing: warningMsg))")
            print("argument message: \(String(describing: argumentMsg))")
            
        }, failure: { (error) in
            
            // 실패
            //UIAlertController.showMessage(error.localizedDescription)
            print("error \(error)")
            
        })
    }
}
