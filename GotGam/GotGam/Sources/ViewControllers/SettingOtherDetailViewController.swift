//
//  SettingOtherDetailViewController.swift
//  GotGam
//
//  Created by 김삼복 on 30/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import Foundation

class SettingOtherDetailViewController: BaseViewController, ViewModelBindableType {
	var viewModel: SettingOtherDetailViewModel!
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		presentationController?.delegate = self
		
		
	}
	
	func bindViewModel() {
		
	}
	
}

extension SettingOtherDetailViewController: UIAdaptivePresentationControllerDelegate {
	
	// MARK: UIAdaptivePresentationControllerDelegate
	func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
		self.viewModel.sceneCoordinator.close(animated: true, completion: nil)
	}

}
