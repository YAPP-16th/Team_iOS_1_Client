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
    var gotList: Observable<[God]> { get }
}

protocol GotListViewModelType {
    var inputs: GotListViewModelInputs { get }
    var outputs: GotListViewModelOutputs { get }
}


struct God {
    var title: String
}
 

class GotListViewModel: CommonViewModel, GotListViewModelType, GotListViewModelInputs, GotListViewModelOutputs {
    
    var inputs: GotListViewModelInputs { return self }
    var outputs: GotListViewModelOutputs { return self }
    
    // Outputs
    
    let gotArr = [
        God(title: "곳감"),
        God(title: "땡감"),
        God(title: "밀감")
    ]
    
    var gotList: Observable<[God]> {
        return Observable.just(gotArr)
    }
    
}
