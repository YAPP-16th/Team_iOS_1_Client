//
//  AddViewModel.swift
//  GotGam
//
//  Created by woong on 26/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol AddViewModelInputs {
    
}

protocol AddViewModelOutputs {
    
}

protocol AddViewModelType {
    var inputs: AddViewModelInputs { get }
    var outputs: AddViewModelOutputs { get }
}


class AddViewModel: AddViewModelType, AddViewModelInputs, AddViewModelOutputs {
    
    var inputs: AddViewModelInputs { return self }
    var outputs: AddViewModelOutputs { return self }
    
    
    
}
