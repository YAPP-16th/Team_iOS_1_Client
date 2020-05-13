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
    
    // MARK: - Properties
    
    var viewModel: GotListViewModel!
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Methods
    
	@IBOutlet var ListAddButton: UIButton!
	@IBAction func moveAddVC(_ sender: Any) {
		viewModel.inputs.showVC()

	}
	// MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureSearchController()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        //memos = DBManager.share.fetchGotgam()
        gotListTableView.reloadData()
    }
    
    // MARK: - Initializing
    
//    func configureSearchController() {
//        searchController.searchResultsUpdater = self
//        navigationItem.searchController = searchController
//    }
    
    func bindViewModel() {
        
        tagCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    
//        viewModel.outputs.gotList
//            .bind(to: gotListTableView.rx.items(cellIdentifier: "gotListCell", cellType: GotListTableViewCell.self)) { (index, got, cell) in
//                cell.configure(got)
//            }
//            .disposed(by: disposeBag)

        viewModel.outputs.tagList
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "tagListCell", cellType: TagListCollectionViewCell.self)) { (index, tag, cell) in
                cell.configure(tag)
                cell.layer.cornerRadius = cell.bounds.height/2
                cell.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 3), opacity: 0.2)
            }
            .disposed(by: disposeBag)
    }

    
    // MARK: - Views

    @IBOutlet weak var gotListTableView: UITableView!
    @IBOutlet var tagCollectionView: UICollectionView!
}

extension GotListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let title = viewModel.outputs.tagList.value[indexPath.item].name
        let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
        
        // 8 + 태그뷰 + 8 + 글자 +
        let width: CGFloat = 8 + 15 + 8 + rect.width + 8
        // cell height - inset(10)
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: 16, bottom: -5, right: 0)
    }
    
    
}
    


//extension GotListViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        // filter
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return memos.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "gotListCell", for: indexPath)
//        let amemos = memos[indexPath.row]
//        cell.textLabel?.text = amemos.title
//
//        return cell
//
//    }
//}
