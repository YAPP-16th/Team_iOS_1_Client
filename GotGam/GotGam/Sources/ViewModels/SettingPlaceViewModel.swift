//
//  SettingPlaceViewModel.swift
//  GotGam
//
//  Created by 김삼복 on 14/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift


protocol SettingPlaceViewModelInputs {
	
}

protocol SettingPlaceViewModelOutputs {

}

protocol SettingPlaceViewModelType {
    var inputs: SettingPlaceViewModelInputs { get }
    var outputs: SettingPlaceViewModelOutputs { get }
}


class SettingPlaceViewModel: CommonViewModel, SettingPlaceViewModelType, SettingPlaceViewModelInputs, SettingPlaceViewModelOutputs {
	
	
    var inputs: SettingPlaceViewModelInputs { return self }
    var outputs: SettingPlaceViewModelOutputs { return self }
    

	
    
}
