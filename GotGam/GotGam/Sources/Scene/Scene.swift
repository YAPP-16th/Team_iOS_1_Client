//
//  Scene.swift
//  GotGam
//
//  Created by woong on 04/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

enum Scene {
    case map(MapViewModel)
    //case list
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .map(let viewModel):
            guard var mapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as? MapViewController else {
                fatalError()
            }
            
            mapVC.bind(viewModel: viewModel)
            
            return mapVC
        }
    }
}
