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
    
    func showMoreActionSheet(at indexPath: IndexPath) {
        guard let cell = gotListTableView.cellForRow(at: indexPath) as? GotListTableViewCell else { return }
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let gamAction = UIAlertAction(title: "감", style: .default) { (action) in
            cell.isChecked = true
        }
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] (action) in
            if let vc = self { vc.gotListTableView.dataSource?.tableView?(vc.gotListTableView, commit: .delete, forRowAt: indexPath)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(gamAction)
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
    
	// MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        listAddButton.layer.cornerRadius = listAddButton.bounds.height/2
        listAddButton.shadow(radius: 3, color: .black, offset: .init(width: 0, height: 2), opacity: 0.16)
        
        tagCollectionView.allowsMultipleSelection = true
        let tagNibName = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagNibName, forCellWithReuseIdentifier: "tagCell")
        let tagListNibName = UINib(nibName: "TagListCollectionViewCell", bundle: nil)
        tagCollectionView.register(tagListNibName, forCellWithReuseIdentifier: "tagListCollectionViewCell")
        
        gotListTableView.dragInteractionEnabled = true
        gotListTableView.dragDelegate = self
        gotListTableView.dropDelegate = self
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        viewModel.inputs.fetchRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Initializing
    
    func bindViewModel() {
        
        gotListTableView.rx.setDelegate(self).disposed(by: disposeBag)
        tagCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        tagCollectionView.allowsSelection = true
        
        // Outputes
        
        let dataSource = GotListViewController.dataSource(viewModel: viewModel, vc: self)
        viewModel.outputs.gotSections
            .bind(to: gotListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.outputs.tagList
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
        
        // Inputs
        
        gotBoxButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.gotBoxSubject)
            .disposed(by: disposeBag)
        
        searchTextField.rx.text.orEmpty
            .debounce(.milliseconds(800), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.filteredGotSubject)
            .disposed(by: disposeBag)
        
        Observable.zip(gotListTableView.rx.itemDeleted, gotListTableView.rx.modelDeleted(ListItem.self))
            .bind { [weak self] indexPath, gotItem in
                if case let .gotItem(got) = gotItem {
                    self?.viewModel.inputs.removeGot(indexPath: indexPath, got: got)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(gotListTableView.rx.itemSelected, gotListTableView.rx.modelSelected(ListItem.self))
            .bind { [weak self] indexPath, gotItem in
                if case let .gotItem(got) = gotItem {
                    self?.viewModel.inputs.editGot(got: got)
                }
            }
            .disposed(by: disposeBag)
        
        gotListTableView.rx.itemMoved
            .asDriver()
            .drive(onNext: { [weak self] source, destination in
                guard source != destination else { return }
                //print("👀 \(source), \(destination)")
                self?.viewModel.inputs.changeIndex(at: source, to: destination)
                //self?.gotListTableView.moveRow(at: source, to: destination)
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
        
        
    }

    
    // MARK: - Views

    @IBOutlet weak var gotListTableView: UITableView!
    @IBOutlet var tagCollectionView: UICollectionView!
    @IBOutlet var gotBoxButton: UIButton!
    @IBOutlet var searchTextField: UITextField!
    
}

extension GotListViewController {
    
    static func dataSource(viewModel: GotListViewModel, vc: GotListViewController?) -> RxTableViewSectionedAnimatedDataSource<ListSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<ListSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .left,
                reloadAnimation: .fade,
                deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case let .gotItem(got):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "gotListCell", for: indexPath) as? GotListTableViewCell else { return UITableViewCell() }
                    cell.configure(viewModel: viewModel, got)
                    cell.moreButton.tag = indexPath.row
                    cell.moreAction = {
                        vc?.showMoreActionSheet(at: indexPath)
                    }
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
            },
            canMoveRowAtIndexPath: { dataSource, index in
                return true
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
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self?.gotListTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let gamAction = UIContextualAction(style: .normal, title: "감") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            guard let cell = tableView.cellForRow(at: indexPath) as? GotListTableViewCell else { return }
            cell.isChecked = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.viewModel.inputs.fetchRequest()
            }
            success(true)
        }
        gamAction.backgroundColor = .saffron
        return UISwipeActionsConfiguration(actions: [gamAction])
    }
}

extension GotListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension GotListViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}

// MARK: - UICollectionView Delegate

extension GotListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

// MARK: - UICollectionView Delegate FlowLayout

extension GotListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 8 + 태그뷰
        var tagWidth: CGFloat = 0
        var title = "태그 목록"
        
        //마지막 셀 = 태그목록
        if indexPath.item != collectionView.numberOfItems(inSection: 0) - 1 {
            tagWidth = 8 + 15
            title = viewModel.outputs.tagList.value[indexPath.item].name
        }
        
        let rect = NSString(string: title).boundingRect(with: .init(width: 0, height: 30), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
        
        // tagWidth + 8 + 글자
        let width: CGFloat = tagWidth + 8 + rect.width + 8
        // cell height - inset(10)
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }
}
