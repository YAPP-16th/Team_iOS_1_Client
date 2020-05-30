//
//  TutorialViewModel.swift
//  GotGam
//
//  Created by 손병근 on 2020/05/30.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
protocol TutorialViewModelInputs{
    
}

protocol TutorialViewModelOutputs{
    
}

protocol TutorialViewModelType{
    var input: TutorialViewModelInputs { get }
    var output: TutorialViewModelOutputs { get }
}

class TutorialViewModel: CommonViewModel, TutorialViewModelType, TutorialViewModelInputs, TutorialViewModelOutputs{
    
    var input: TutorialViewModelInputs { return self }
    var output: TutorialViewModelOutputs { return self }
    
    
}
