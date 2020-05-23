//
//  GotBoxViewController.swift
//  GotGam
//
//  Created by woong on 23/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GotBoxViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: GotBoxViewModel!
    
    // MARK: - Methods
    
    func showMoreActionSheet(at indexPath: IndexPath) {
        
        guard let cell = gotBoxListTableView.cellForRow(at: indexPath) as? GotBoxTableViewCell else { return }
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let recoverAction = UIAlertAction(title: "되돌리기", style: .default) { [weak self] (action) in
            self?.viewModel.inputs.recover(got: cell.got, at: indexPath)
        }
        
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] (action) in
            if let vc = self {
                vc.gotBoxListTableView.dataSource?.tableView?(vc.gotBoxListTableView, commit: .delete, forRowAt: indexPath)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            
        }
        
        actionSheet.addAction(recoverAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true) {
            
        }
    }
    
    // MARK: - Initailizing

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "TagCollectionViewCell", bundle: nil)

        gotBoxListTableView.register(nibName, forCellReuseIdentifier: "tagCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchRequest()
    }
    
    func bindViewModel() {
        
        gotBoxListTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Inputs
        
        Observable.zip(gotBoxListTableView.rx.itemDeleted, gotBoxListTableView.rx.modelDeleted(BoxItem.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                switch item {
                case let .gotItem(got):
                    self?.viewModel.inputs.delete(got: got, at: indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        
        // Outputs
        
        let dataSource = GotBoxViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.boxSections
            .bind(to: gotBoxListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    @IBOutlet var gotBoxListTableView: UITableView!
}

extension GotBoxViewController {
    static func dataSource(viewModel: GotBoxViewModel, vc: GotBoxViewController?) -> RxTableViewSectionedAnimatedDataSource<BoxSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<BoxSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .left,
                reloadAnimation: .fade,
                deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case let .gotItem(got):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "gotBoxCell", for: indexPath) as? GotBoxTableViewCell else { return UITableViewCell() }
                    cell.configure(viewModel: viewModel, got: got)
                    cell.moreAction = { vc?.showMoreActionSheet(at: indexPath) }
//                    cell.moreButton.tag = indexPath.row
//                    cell.moreAction = {
//                        vc?.showMoreActionSheet(at: indexPath)
//                    }
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

extension GotBoxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let recoverAction = UIContextualAction(style: .normal, title: "되돌리기") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            guard let cell = tableView.cellForRow(at: indexPath) as? GotBoxTableViewCell else { return }

            self?.viewModel.inputs.recover(got: cell.got, at: indexPath)

            success(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            self?.gotBoxListTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)

            success(true)
        }
        
        recoverAction.backgroundColor = .saffron
        return .init(actions: [deleteAction, recoverAction])
    }
}
