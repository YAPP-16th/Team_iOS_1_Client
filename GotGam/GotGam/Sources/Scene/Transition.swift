//
//  Transition.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

enum Transition {
    case root
    case push
    case modal
    case fullScreen
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
