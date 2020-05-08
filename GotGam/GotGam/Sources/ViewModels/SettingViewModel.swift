//
//  SettingViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation


protocol SettingViewModelInputs {
    
}

protocol SettingViewModelOutputs {
    
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInputs { get }
    var outputs: SettingViewModelOutputs { get }
}


class SettingViewModel: CommonViewModel, SettingViewModelType, SettingViewModelInputs, SettingViewModelOutputs {
    
    var inputs: SettingViewModelInputs { return self }
    var outputs: SettingViewModelOutputs { return self }
    

    
}
