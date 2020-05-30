//
//  ShareListViewController.swift
//  GotGam
//
//  Created by woong on 24/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ShareListViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: ShareListViewModel!
    
    // MARK: - Methods
    
    func showShareAlert(tag: Tag, at: IndexPath) {
        let alert = UIAlertController(title: "'\(tag.name)'태그를 공유하시겠습니까?", message: "태그를 공유해서 더 많은 사람들에게\n나의 공간들을 알려보아요.", preferredStyle: .alert)
        let shareAction = UIAlertAction(title: "공유", style: .default) { [weak self] (action) in
            self?.viewModel.inputs.share(tag: tag)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(shareAction)
        present(alert, animated: true)
    }
    
    // MARK: - Initializing

    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchTagList()
    }
    
    func bindViewModel() {
        
        shareListTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Inputs
        
        addTagButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.addTagSubject)
            .disposed(by: disposeBag)
        
        // Outputs
        
        let dataSources = ShareListViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.shareListDataSources
            .bind(to: shareListTableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)
        
        shareListTableView.rx.modelSelected(ShareItem.self)
            .subscribe(onNext: { [weak self] item in
                if case let .shareItem(tag) = item {
                    self?.viewModel.showCreateTag(tag: tag)
                }
            })
            .disposed(by: disposeBag)
        
        Observable.zip(shareListTableView.rx.itemDeleted, shareListTableView.rx.modelDeleted(ShareItem.self))
            .subscribe(onNext: { [weak self] indexPath, item in
                
                switch item {
                case let .shareItem(tag):
                    self?.viewModel.inputs.remove(tag: tag, at: indexPath)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Views
    
    @IBOutlet var shareListTableView: UITableView!
    @IBOutlet var addTagButton: UIBarButtonItem!
}

extension ShareListViewController {
    static func dataSource(viewModel: ShareListViewModel, vc: ShareListViewController) -> RxTableViewSectionedAnimatedDataSource<ShareSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<ShareSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .left,
                reloadAnimation: .fade,
                deleteAnimation: .left),
            configureCell: { ds, tv, indexPath, item in
                switch item {
                case let .shareItem(tag):
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "shareCell", for: indexPath) as? ShareListTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(viewModel: viewModel, tag: tag)
                    cell.shareAction = {vc.showShareAlert(tag: tag, at: indexPath)}
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            },
            canEditRowAtIndexPath: { dataSource, index in
                return true
            }
            
        )
    }
}

extension ShareListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "수정") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self?.viewModel.inputs.updateTag(at: indexPath)
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in self?.shareListTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
        }
        
        return .init(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = tableView.backgroundColor
    }
}

extension ShareListViewController: UIAdaptivePresentationControllerDelegate {
    // MARK: UIAdaptivePresentationControllerDelegate

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.viewModel.sceneCoordinator.close(animated: true, completion: nil)
    }
}
