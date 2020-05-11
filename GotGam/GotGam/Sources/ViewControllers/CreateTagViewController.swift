//
//  CreateTagViewController.swift
//  GotGam
//
//  Created by woong on 06/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CreateTagViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: CreateTagViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        createTagTableView.rowHeight = UITableView.automaticDimension
        createTagTableView.estimatedRowHeight = 600
    }
    
    func bindViewModel() {
        createTagTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let dataSource = CreateTagViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.sections
            .bind(to: createTagTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.save)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Views
    
    @IBOutlet var createTagTableView: UITableView!
    @IBOutlet var saveButton: UIBarButtonItem!
}

extension CreateTagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .groupTableViewBackground
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

extension CreateTagViewController {
    static func dataSource(viewModel: CreateTagViewModel) -> RxTableViewSectionedReloadDataSource<CreateTagSectionModel> {
        return RxTableViewSectionedReloadDataSource<CreateTagSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .TextFieldItem(text, placeholder):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "createNameCell", for: indexPath) as? CreateTextFieldTableViewCell else { return UITableViewCell()}
                    cell.viewModel = viewModel
                    return cell
                    
                case .GridItem:
                    guard let cell = table.dequeueReusableCell(withIdentifier: "createGridCell", for: indexPath) as? CreateGridTableViewCell else { return UITableViewCell()}
                    cell.viewModel = viewModel
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
