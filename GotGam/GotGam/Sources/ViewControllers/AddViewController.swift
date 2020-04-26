//
//  AddViewController.swift
//  GotGam
//
//  Created by woong on 26/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: AddViewModel!

    // MARK: - Methods
    
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.close()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func bindViewModel() {
        
    }
    
    // MARK: - Views
}

extension AddViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.viewModel.close()
    }
}
