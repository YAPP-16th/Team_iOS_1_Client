//
//  SettingViewController.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: BaseViewController, ViewModelBindableType {
	
    var viewModel: SettingViewModel!

	@IBOutlet var settingTableView: UITableView!
	
	@IBOutlet var loginView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
	override func viewDidLoad() {
        super.viewDidLoad()
		
		loginView.isUserInteractionEnabled = true
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
		loginView.addGestureRecognizer(tapRecognizer)
    
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.inputs.updateUserInfo()
      NetworkAPIManagerTest.shared.uploadAllTags()
    }
	
	@objc func loginTapped(sender: UIView) {
		self.viewModel.inputs.showLoginDetailVC()
	}
	
	func bindViewModel() {
		
		settingTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)


		viewModel.outputs.settingMenu
			.bind(to: settingTableView.rx.items(cellIdentifier: "settingCell")) {
				(index: Int, element: String, cell: SettingListCell) in

				cell.settingListLabel?.text = element

		}.disposed(by: disposeBag)
		
		
		
		settingTableView.rx.itemSelected
			.subscribe(onNext: { [weak self] (indexPath) in
				if indexPath.row == 0 {
					self?.viewModel.inputs.showAlarmDetailVC()
				} else if indexPath.row == 1 {
					self?.viewModel.inputs.showPlaceDetailVC()
				} else if indexPath.row == 2 {
					self?.viewModel.inputs.showOtherDetailVC()
				}
			})
			.disposed(by: disposeBag)
				
        self.viewModel.outputs.userInfo.bind { user in
            if let user = user{
                self.nicknameLabel.text = user.nickname
                self.emailLabel.text = user.userID
                self.viewModel.inputs.getProfileImage(url: user.profileImageURL)
            }else{
                self.nicknameLabel.text = "로그인이 필요합니다"
                self.emailLabel.text = ""
                self.profileImageView.image = UIImage(named: "icsettingLogin")
            }
            
        }.disposed(by: disposeBag)
        
        self.viewModel.profileImage.bind(to: self.profileImageView.rx.image)
        .disposed(by: disposeBag)
	}
}



extension SettingViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.borderWidth = 0.3
		view.layer.borderColor = UIColor.lightGray.cgColor
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		settingTableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingListCell: UITableViewCell {
	@IBOutlet var settingListLabel: UILabel!
}
