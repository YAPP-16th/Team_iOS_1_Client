//
//  AlarmViewController.swift
//  GotGam
//
//  Created by woong on 08/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AlarmViewController: BaseViewController, ViewModelBindableType {
    
    var viewModel: AlarmViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func bindViewModel() {
        alarmTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let dataSource = AlarmViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.dataSource
            .bind(to: alarmTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @IBOutlet var alarmTableView: UITableView!
}

extension AlarmViewController {
    static func dataSource(viewModel: AlarmViewModel) -> RxTableViewSectionedReloadDataSource<AlarmSectionModel> {
        return RxTableViewSectionedReloadDataSource<AlarmSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .ArriveItem(got):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "arriveCell", for: indexPath) as? AlarmArriveTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel, got: got)
                    return cell
                    
                case .LeaveItem:
                    guard let cell = table.dequeueReusableCell(withIdentifier: "createGridCell", for: indexPath) as? AlarmLeaveTableViewCell else { return UITableViewCell()}
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

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
