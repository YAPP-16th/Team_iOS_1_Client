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
    func close()
}

protocol AddViewModelOutputs {
    //var detailItem: DetailItem { get }
}

protocol AddViewModelType {
    var inputs: AddViewModelInputs { get }
    var outputs: AddViewModelOutputs { get }
}


class AddViewModel: CommonViewModel, AddViewModelType, AddViewModelInputs, AddViewModelOutputs {
    
    // MARK: - Constants
    
    
    // MARK: - Variables
    
    var inputs: AddViewModelInputs { return self }
    var outputs: AddViewModelOutputs { return self }
    
    
    // MARK: - Input
    func close() {
        sceneCoordinator.close(animated: true)
    }
    
    // MARK: - Output
    //var detailItem: DetailItem
}
