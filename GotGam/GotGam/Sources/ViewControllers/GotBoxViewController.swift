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
