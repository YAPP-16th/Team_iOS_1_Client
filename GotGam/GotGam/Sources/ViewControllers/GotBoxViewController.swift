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
        tagCollectionView.register(nibName, forCellWithReuseIdentifier: "tagCell")
        tagCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchRequest()
    }
    
    func bindViewModel() {
        
        
        gotBoxListTableView.rx.setDelegate(self).disposed(by: disposeBag)
        tagCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
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
        
        viewModel.outputs.tagListRelay
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "tagCell", cellType: TagCollectionViewCell.self)) { (index, tag, cell) in
                cell.configure(tag)
                cell.layer.cornerRadius = cell.bounds.height/2
            }
            .disposed(by: disposeBag)
        
        let dataSource = GotBoxViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.boxSections
            .bind(to: gotBoxListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    @IBOutlet var gotBoxListTableView: UITableView!
    @IBOutlet var tagCollectionView: UICollectionView!
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

extension GotBoxViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.contentView.alpha = 0.3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            
            cell.contentView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.contentView.alpha = 0.3
        }
    }
}

extension GotBoxViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let title = viewModel.outputs.tagListRelay.value[indexPath.item].name
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
