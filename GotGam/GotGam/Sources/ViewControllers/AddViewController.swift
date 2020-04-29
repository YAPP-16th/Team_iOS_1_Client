//
//  AddViewController.swift
//  GotGam
//
//  Created by 김삼복 on 29/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
	
	
	@IBOutlet var txtTitle: UITextField!
	
	   
	@IBOutlet var txtLocation: UITextField!
	
	   
	@IBOutlet var txtMemo: UITextField!
	
	
	override func viewDidLoad() {
		   super.viewDidLoad()

		   
	   }
	   
	
	@IBAction func onClickAdd(_ sender: Any) {
		   if let title = txtTitle.text, let tag = txtLocation.text, let memo = txtMemo.text {
			   let newMemo = Gotgam(context: DBManager.share.context)
			   newMemo.title = title
			   //newMemo.date = date
			   newMemo.tag = tag
			   newMemo.content = memo
			   DBManager.share.saveContext()
			   //print("성공")
		   }
	}
}
