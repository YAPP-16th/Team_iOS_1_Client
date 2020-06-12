//
//  SettingLoginViewController.swift
//  GotGam
//
//  Created by 김삼복 on 20/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit

class SettingLoginViewController: BaseViewController, ViewModelBindableType {

	var viewModel: SettingLoginViewModel!
	
	@IBOutlet var settingLoginTableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
        self.viewModel.inputs.getUserInfo()
	}
	
	func bindViewModel() {
		settingLoginTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
        
		viewModel.outputs.settingLoginMenu
			.bind(to: settingLoginTableView.rx.items(cellIdentifier: "settingLoginCell")) {
				(index: Int, element: String, cell: SettingLoginCell) in
				cell.settingLoginLabel?.text = element
		}.disposed(by: disposeBag)
        
        self.viewModel.outputs.userInfo.bind { user in
            self.nicknameLabel.text = user.nickname
            self.emailLabel.text = user.userID
            self.viewModel.inputs.getProfileImage(url: user.profileImageURL)
        }.disposed(by: disposeBag)
        
        self.viewModel.outputs.profileImage.bind(to: self.profileImageView.rx.image)
        .disposed(by: disposeBag)
        
	}
		
}

extension SettingLoginViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}
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
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.viewModel.inputs.logout()
        }else if indexPath.row == 1{
            let alert = UIAlertController(title: "경고", message: "회원탈퇴 하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "네", style: .default, handler: { (_) in
                self.viewModel.inputs.leave()
            }))
            alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
            self.present(alert, animated: false, completion: nil)

        }
		settingLoginTableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingLoginCell: UITableViewCell {
	@IBOutlet var settingLoginLabel: UILabel!
	
}
