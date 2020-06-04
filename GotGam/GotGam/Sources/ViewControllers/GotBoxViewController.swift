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
            if let vc = self { vc.gotBoxListTableView.dataSource?.tableView?(vc.gotBoxListTableView, commit: .delete, forRowAt: indexPath)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
        }
        actionSheet.addAction(recoverAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    func appendEmptyTag(_ tags: [Tag]) -> [Tag] {
        var tags = tags
        let emptyTag = Tag(name: "", hex: "empty")
        tags.append(emptyTag)
        return tags
    }
    
    // MARK: - Initailizing

    override func viewDidLoad() {
        super.viewDidLoad()

        tagCollectionView.allowsMultipleSelection = true
        let tagNibName = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagNibName, forCellWithReuseIdentifier: "tagCell")
        let tagListNibName = UINib(nibName: "TagListCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagListNibName, forCellWithReuseIdentifier: "tagListCollectionViewCell")
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
        
        Observable.zip(tagCollectionView.rx.itemSelected, tagCollectionView.rx.modelSelected(Tag.self))
            .bind { [weak self] indexPath, tag in
                
                if let collectionView = self?.tagCollectionView, indexPath.item == collectionView.numberOfItems(inSection: 0)-1 {
                    self?.viewModel.inputs.tagListCellSelect.onNext(())
                    return
                }
                
                if var tags = self?.viewModel.inputs.filteredTagSubject.value {
                    tags.append(tag)
                    self?.viewModel.inputs.filteredTagSubject.accept(tags)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tagCollectionView.rx.itemDeselected, tagCollectionView.rx.modelDeselected(Tag.self))
            .bind { [weak self] indexPath, tag in
                if var tags = self?.viewModel.inputs.filteredTagSubject.value, let index = tags.firstIndex(of: tag) {
                    tags.remove(at: index)
                    self?.viewModel.inputs.filteredTagSubject.accept(tags)
                }
            }
            .disposed(by: disposeBag)
        
        // Outputs
        
        viewModel.outputs.tagListRelay
            .compactMap { [weak self] in self?.appendEmptyTag($0) }
            .bind(to: tagCollectionView.rx.items) { [weak self] (collectionView, cellItem, tag) -> UICollectionViewCell in
                if cellItem != collectionView.numberOfItems(inSection: 0)-1 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: IndexPath(item: cellItem, section: 0)) as? TagCollectionViewCell else { return UICollectionViewCell()}
                    if self?.viewModel.outputs.emptyTagList.value.contains(tag) ?? false {
                        cell.isEmpty = true
                    } else {
                        cell.isEmpty = false
                    }
                    cell.configure(tag)
                    cell.layer.cornerRadius = cell.bounds.height/2
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListCollectionViewCell", for: IndexPath(item: cellItem, section: 0)) as? TagListCollectionViewCell else { return UICollectionViewCell()}
                    cell.layer.cornerRadius = cell.bounds.height/2
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        let dataSource = GotBoxViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.boxSections
            .bind(to: gotBoxListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Views
    
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

extension GotBoxViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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

// MARK: - UICollectionView Delegate

extension GotBoxViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.contentView.alpha = 0.3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            guard !cell.isEmpty else { return }
            cell.contentView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.contentView.alpha = 0.3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            guard !cell.isEmpty else { return }
            cell.contentView.alpha = 1
        }
    }
}

// MARK: - UICollectionView DelegateFlowLayout

extension GotBoxViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 8 + 태그뷰
        var tagWidth: CGFloat = 0
        var title = "태그 목록"
        
        //마지막 셀 = 태그목록
        if indexPath.item != collectionView.numberOfItems(inSection: 0) - 1 {
            tagWidth = 8 + 15
            title = viewModel.outputs.tagListRelay.value[indexPath.item].name
        }
        
        let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
        
        // tagWidth + 8 + 글자
        let width: CGFloat = tagWidth + 8 + rect.width + 8
        // cell height - inset(10)
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }
}
