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
    
    // MARK: - Views
    @IBOutlet weak var gotListTableView: UITableView!


    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
    }
    
    // MARK: - Initializing
    
    func configureSearchController() {
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    func bindViewModel() {
        
//        viewModel.outputs.gotList
//            .bind(to: gotListTableView.rx.items(cellIdentifier: "gotListCell", cellType: UITableViewCell.self)) { index, got, cell in
//                print(got.title)
//                cell.textLabel?.text = got.title
//            }
//            .disposed(by: disposeBag)
      viewModel.memoList
                 .bind(to: gotListTableView.rx.items(cellIdentifier: "gotListCell", cellType: UITableViewCell.self)) { row, got, cell in
                       //print(got.title)
                        cell.textLabel?.text = got.title
                }
      .disposed(by: disposeBag)
           

      }

   }
    


extension GotListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // filter
    }
}
