//
//  FrequentsMapViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 27/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


protocol FrequentsMapViewModelInputs {

}

protocol FrequentsMapViewModelOutputs {
	var frequentsPlaceMap: BehaviorRelay<Place?> { get set }
}

protocol FrequentsMapViewModelType {
	var inputs: FrequentsMapViewModelInputs { get }
	var outputs: FrequentsMapViewModelOutputs { get }
}

class FrequentsMapViewModel: CommonViewModel, FrequentsMapViewModelInputs, FrequentsMapViewModelOutputs, FrequentsMapViewModelType {
	
	var inputs: FrequentsMapViewModelInputs { return self }
    var outputs: FrequentsMapViewModelOutputs { return self }
	var frequentsPlaceMap = BehaviorRelay<Place?>(value:nil)
	var currentPlace = BehaviorRelay<Place?>(value:nil)
	
	var placeBehavior = BehaviorRelay<Place?>(value: nil)
	
}
