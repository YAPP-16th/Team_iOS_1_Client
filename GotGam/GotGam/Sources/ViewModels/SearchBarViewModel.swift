//
//  SearchBarViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SearchBarViewModelInputs {
//	var inputText: BehaviorSubject<String> { get set }
}

protocol SearchBarViewModelOutputs {
//	var placeText: BehaviorSubject<String> { get }
//    var tag: BehaviorSubject<String?> { get }
//    var keyword: BehaviorSubject<String> { get }
//	var history: BehaviorSubject<String> { get }
	
}

protocol SearchBarViewModelType {
	var inputs: SearchBarViewModelInputs { get }
	var outputs: SearchBarViewModelOutputs { get }
}

class SearchBarViewModel: CommonViewModel, SearchBarViewModelInputs, SearchBarViewModelOutputs, SearchBarViewModelType {
	//input
//	var inputText: BehaviorSubject<String>
	
	//output
//	var placeText: BehaviorSubject<String>
//	var tag: BehaviorSubject<String?>
//	var keyword: BehaviorSubject<String>
//	var history: BehaviorSubject<String>
	
	
	var inputs: SearchBarViewModelInputs { return self }
    var outputs: SearchBarViewModelOutputs { return self }
	
	
}
