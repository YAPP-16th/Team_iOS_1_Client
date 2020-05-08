//
//  AlarmViewModel.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation


protocol AlarmViewModelInputs {
    
}

protocol AlarmViewModelOutputs {
    
}

protocol AlarmViewModelType {
    var inputs: AlarmViewModelInputs { get }
    var outputs: AlarmViewModelOutputs { get }
}


class AlarmViewModel: CommonViewModel, AlarmViewModelType, AlarmViewModelInputs, AlarmViewModelOutputs {

    var inputs: AlarmViewModelInputs { return self }
    var outputs: AlarmViewModelOutputs { return self }
}
