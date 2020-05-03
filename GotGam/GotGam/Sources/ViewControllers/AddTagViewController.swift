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

class AddTagViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: AddTagViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        
        viewModel.outputs.sections
            .bind(to: tagTableView.rx.items(dataSource: AddTagViewController.dataSource()))
            .disposed(by: disposeBag)
        
    }
    
    @IBOutlet var tagTableView: UITableView!
    
}

extension AddTagViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<AddTagSectionModel> {
        return RxTableViewSectionedReloadDataSource<AddTagSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .SelectedTagItem(title, tag):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "selectedTagCell", for: indexPath) as? AddSelectedTagTableViewCell else { return UITableViewCell()}
                    cell.configure(title: title, tag: tag)
                    return cell
                case let .TagListItem(tag, selectedTag):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "tagListCell", for: indexPath) as? AddTagListTableViewCell else { return UITableViewCell()}
                    cell.configure(tag: tag, selected: selectedTag)
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
