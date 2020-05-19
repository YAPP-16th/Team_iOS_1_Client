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
import RxDataSources

class GotListViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: GotListViewModel!
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Methods
    
	@IBOutlet var listAddButton: UIButton!
	@IBAction func moveAddVC(_ sender: Any) {
        viewModel.inputs.editGot(got: nil)

	}
	// MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureSearchController()
        listAddButton.layer.cornerRadius = listAddButton.bounds.height/2
        listAddButton.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        viewModel.inputs.fetchRequest()
    }
    
    // MARK: - Initializing
    
//    func configureSearchController() {
//        searchController.searchResultsUpdater = self
//        navigationItem.searchController = searchController
//    }
    
    func bindViewModel() {
        
        gotListTableView.rx.setDelegate(self).disposed(by: disposeBag)
        tagCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Inputs
        
        Observable.zip(gotListTableView.rx.itemDeleted, gotListTableView.rx.modelDeleted(ListItem.self))
            .bind { [weak self] indexPath, gotItem in
                if case let .gotItem(got) = gotItem {
                    self?.viewModel.inputs.removeGot(indexPath: indexPath, got: got)
                }
                
            }
            .disposed(by: disposeBag)
        
        // Outputes
        
        let dataSource = GotListViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.gotSections
            .bind(to: gotListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

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

extension GotListViewController {
    static func dataSource(viewModel: GotListViewModel) -> RxTableViewSectionedAnimatedDataSource<ListSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<ListSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .top,
                reloadAnimation: .fade,
                deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case let .gotItem(got):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "gotListCell", for: indexPath) as? GotListTableViewCell else { return UITableViewCell() }
                    cell.configure(viewModel: viewModel, got)
                    
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            },
            canEditRowAtIndexPath: { dataSource, index in
                let section = dataSource[index]
                switch section {
                case .gotItem(_):
                    return true
                }
            }
        )
    }
}

// MARK: - UITableView Delegate

extension GotListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let gamAction = UIContextualAction(style: .normal, title: "감") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            guard let cell = tableView.cellForRow(at: indexPath) as? GotListTableViewCell else { return }

            cell.isChecked = true

            success(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            guard let cell = tableView.cellForRow(at: indexPath) as? GotListTableViewCell else { return }

            self?.viewModel.inputs.editGot(got: cell.got)

            success(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            self.gotListTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)

            success(true)
        }

        gamAction.backgroundColor = .saffron
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, gamAction])
    }
}

// MARK: - UICollectionView Delegate

extension GotListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionView Delegate FlowLayout

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
        return .init(top: 5, left: 16, bottom: 5, right: 0)
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
