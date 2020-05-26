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
    
    // MARK: - Methods
    
    func moveIndicator(to category: AlarmCategoryType) {
        if category == .active {
            UIView.animate(withDuration: 0.5) {
                self.activeIndeicatorView.transform = .identity
            }
        } else if category == .share {
            UIView.animate(withDuration: 0.5) {
                self.activeIndeicatorView.transform = CGAffineTransform(translationX: self.activeButton.frame.width, y: 0)
            }
            
        }
        
    }
    
    // MARK: - Initializing

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        alarmTableView.layer.borderWidth = 0.2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchAlarmList()
    }

    func bindViewModel() {
        alarmTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Inputs
        
        activeButton.rx.tap
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.tappedActive)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.tappedShare)
            .disposed(by: disposeBag)
        
        Observable.zip(alarmTableView.rx.itemSelected, alarmTableView.rx.modelSelected(AlarmItem.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                switch item {
                case let .ArriveItem(alarm):
                    self?.viewModel.inputs.checkAlarm.onNext(alarm)
                case let .DepartureItem(alarm):
                    self?.viewModel.inputs.checkAlarm.onNext(alarm)
                case let .ShareItem(alarm):
                    self?.viewModel.inputs.checkAlarm.onNext(alarm)
                }
                //if let cell = alarmTableView.cellForRow(at: indexPath) as?

            })
            .disposed(by: disposeBag)
        
        Observable.zip(alarmTableView.rx.itemDeleted, alarmTableView.rx.modelDeleted(AlarmItem.self))
            .bind { [weak self] indexPath, item in
                 switch item {
                 case let .ArriveItem(alarm):
                     self?.viewModel.inputs.removeAlarm(indexPath: indexPath, alarm: alarm)
                 case let .DepartureItem(alarm):
                     self?.viewModel.inputs.removeAlarm(indexPath: indexPath, alarm: alarm)
                 case let .ShareItem(alarm):
                     self?.viewModel.inputs.removeAlarm(indexPath: indexPath, alarm: alarm)
                 }
            }
            .disposed(by: disposeBag)
        
        // Outputs
        
        viewModel.outputs.currentAlarm
            .subscribe(onNext: { [weak self] alarmType in
                self?.moveIndicator(to: alarmType)
                if alarmType == .active {
                    self?.activeButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
                    self?.shareButton.titleLabel?.font = .systemFont(ofSize: 14)
                } else if alarmType == .share {
                    self?.activeButton.titleLabel?.font = .systemFont(ofSize: 14)
                    self?.shareButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.activeBadgeCount
            .subscribe(onNext: { [weak self] count in
                if count == 0 {
                    self?.activeButton.addbadgetobutton(badge: nil)
                } else {
                    self?.activeButton.addbadgetobutton(badge: "\(count)")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.sharedBadgeCount
            .subscribe(onNext: { [weak self] count in
                if count == 0 {
                    self?.shareButton.addbadgetobutton(badge: nil)
                } else {
                    self?.shareButton.addbadgetobutton(badge: "\(count)")
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.outputs.activeBadgeCount, viewModel.outputs.sharedBadgeCount)
            .subscribe(onNext: { [weak self] active, shared in
                if let tabItems = self?.tabBarController?.tabBar.items {
                    let count = active + shared
                    
                    tabItems[2].badgeValue = count == 0 ? nil : "\(active + shared)"
                }
            })
            .disposed(by: disposeBag)
        
        let dataSource = AlarmViewController.dataSource(viewModel: viewModel)
        viewModel.outputs.currentDataSource
            .bind(to: alarmTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @IBOutlet var alarmTableView: UITableView!
    @IBOutlet var activeButton: BadgeButton!
    @IBOutlet var shareButton: BadgeButton!
    @IBOutlet var activeIndeicatorView: UIView!
    
}

extension AlarmViewController {
    static func dataSource(viewModel: AlarmViewModel) -> RxTableViewSectionedAnimatedDataSource<AlarmSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<AlarmSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .none,
                reloadAnimation: .fade,
                deleteAnimation: .none),
            
            configureCell: { dataSource, table, indexPath, _ in
                switch dataSource[indexPath] {
                case let .ArriveItem(alarm):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "arriveCell", for: indexPath) as? AlarmArriveTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel, alarm: alarm)
                    return cell
                    
                case let .DepartureItem(alarm):
                    guard let cell = table.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath) as? AlarmDepartureTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel, alarm: alarm)
                    return cell
                case .ShareItem(let alarm):
                    // TODO: - share item cell 변경
                    guard let cell = table.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath) as? AlarmShareTableViewCell else { return UITableViewCell()}
                    cell.configure(viewModel: viewModel, alarm: alarm)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "삭제") { [weak self] (action, view, success: (Bool) -> Void) in
            
            self?.alarmTableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
            
            success(true)
        }
        
        deleteAction.backgroundColor = .saffron
        return .init(actions: [deleteAction])
    }
}
