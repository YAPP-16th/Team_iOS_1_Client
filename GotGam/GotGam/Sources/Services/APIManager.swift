//
//  APIManager.swift
//  GotGam
//
//  Created by 김삼복 on 16/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Alamofire
import RxSwift

class APIManager {
	static let shared = APIManager()
	
	func search(keyword: String, completion: @escaping ([Place]) -> Void){
		let urlString = "https://dapi.kakao.com/v2/local/search/keyword.json"
        let parameters = [
            "y": "37.514322572335935",
            "x": "127.06283102249932",
            "radius": "20000",
            "query": keyword
        ]
		
		let headers:HTTPHeaders = [
			"Authorization": "KakaoAK 5aac55f9c37f8ba7f7c3a1e3c5af6c08"
		]
        AF.request(urlString, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers, interceptor: nil).responseJSON { (response) in
			
			if let data = response.data{
				let jsonDecoder = JSONDecoder()
				let result = try? jsonDecoder.decode(KakaoResponse.self, from: data)
				completion(result.documents)
			} else {
				completion([])
			}
			
        }
	}
}
