//
//  ListViewViewController.swift
//  GotGam
//
//  Created by woong on 17/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GotListViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: GotListViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
  
    var memos = [ManagedGot]()
    
    // MARK: - Views
    @IBOutlet weak var gotListTableView: UITableView!


	@IBOutlet var ListAddButton: UIButton!
	@IBAction func moveAddVC(_ sender: Any) {
		viewModel.inputs.showVC()
	}
	// MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.ListAddButton.layer.shadowColor = UIColor.black.cgColor
        self.ListAddButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.ListAddButton.layer.shadowRadius = 5.0
        self.ListAddButton.layer.shadowOpacity = 0.3
        self.ListAddButton.layer.cornerRadius = 4.0
        self.ListAddButton.layer.masksToBounds = false
		self.ListAddButton.layer.cornerRadius = self.ListAddButton.frame.height / 2
	}
  
    override func viewWillAppear(_ animated: Bool) {
        memos = DBManager.share.fetchGotgam()
        gotListTableView.reloadData()
    }
    
    // MARK: - Initializing
    
    func configureSearchController() {
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    func bindViewModel() {
        
        viewModel.outputs.gotList
                  .bind(to: gotListTableView.rx.items(cellIdentifier: "gotListCell", cellType: UITableViewCell.self)) { index, got, cell in
                      print(got.title)
                cell.textLabel?.text = got.title
            }
            .disposed(by: disposeBag)
      
          
      }

}
    


extension GotListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // filter
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gotListCell", for: indexPath)
        let amemos = memos[indexPath.row]
        cell.textLabel?.text = amemos.title

        return cell
        
    }
}
