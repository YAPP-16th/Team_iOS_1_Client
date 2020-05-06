//
//  AddTagViewController.swift
//  GotGam
//
//  Created by woong on 30/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SetTagViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: SetTagViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        
        tagTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Inputs
        
        
        tagTableView.rx.modelSelected(AddTagSectionModel.Item.self)
            .subscribe(onNext: { item in
                if case let .TagListItem(tag, selected) = item {
                    self.viewModel.selectedTag.accept(tag)
                }
            })
            .disposed(by: disposeBag)
        
        tagTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                if indexPath.section == 2 {
                    self.viewModel.inputs.createTag.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        // Outputs
        
        let dataSource = SetTagViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.sections
            .bind(to: tagTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    @IBOutlet var tagTableView: UITableView!
    
}

extension SetTagViewController {
    static func dataSource(viewModel: SetTagViewModel) -> RxTableViewSectionedReloadDataSource<AddTagSectionModel> {
        return RxTableViewSectionedReloadDataSource<AddTagSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .SelectedTagItem(title, tag):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "selectedTagCell", for: indexPath) as? SetSelectedTagTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel, title: title, tag: tag)
                    return cell
                case let .TagListItem(tag, selectedTag):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "tagListCell", for: indexPath) as? SetTagListTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel,tag: tag, selected: selectedTag)
                    return cell
                case .CreateTagItem(let title):
                    let cell = table.dequeueReusableCell(withIdentifier: "newTagCell", for: indexPath)
                    cell.textLabel?.text = title
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            }
        )
    }
}

extension SetTagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
