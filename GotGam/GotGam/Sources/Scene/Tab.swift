//
//  Tab.swift
//  GotGam
//
//  Created by woong on 18/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

enum Tab {
    static var tabs: [Tab] = []

    case map(viewModel: MapViewModel)
    case list(viewModel: GotListViewModel)
}
