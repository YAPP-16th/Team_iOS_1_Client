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
  
    var memos = [Gotgam]()
    
    // MARK: - Views
    @IBOutlet weak var gotListTableView: UITableView!


    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
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
