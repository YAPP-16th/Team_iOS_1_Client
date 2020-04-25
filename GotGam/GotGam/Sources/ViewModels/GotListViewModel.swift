//
//  ListViewModel.swift
//  GotGam
//
//  Created by woong on 17/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation
import RxSwift

protocol GotListViewModelInputs {
    
}

protocol GotListViewModelOutputs {
    var gotList: Observable<[Got]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
    // Outputs
    
    var gotList: Observable<[Got]> {
        return storage.memoList()
    }
    
}
