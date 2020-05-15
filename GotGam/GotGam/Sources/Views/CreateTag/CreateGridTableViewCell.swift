//
//  CreateGridTableViewCell.swift
//  GotGam
//
//  Created by woong on 07/05/2020.
//  Copyright © 2020 손병근. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateGridTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    var viewModel: CreateTagViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
         colorCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.outputs.tagColors
            .bind(to: colorCollectionView.rx.items(cellIdentifier: "tagColorCell", cellType: TagColorCollectionViewCell.self)) { indexPath, tagColor, cell in
                cell.configure(viewModel: self.viewModel, tagColor: tagColor)
                cell.layer.cornerRadius = cell.bounds.height/2
            }
            .disposed(by: disposeBag)
            
        colorCollectionView.rx.modelSelected(TagColor.self)
            .map { $0.hex }
            .bind(to: viewModel.inputs.tagSelected)
            .disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var colorCollectionView: UICollectionView!
}

extension CreateGridTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 20, left: 10, bottom: 20, right: 10)
    }
    
}

// MARK: - TagColor Cell

class TagColorCollectionViewCell: UICollectionViewCell {
    
    var tagColor: TagColor!
    var viewModel: CreateTagViewModel!
    var disposeBag = DisposeBag()
    
    @IBOutlet var checkImageView: UIImageView!
    
    func configure(viewModel: CreateTagViewModel, tagColor: TagColor) {
        self.viewModel = viewModel
        self.tagColor = tagColor
        backgroundColor = tagColor.color
        
        
        viewModel.newTagHex
            .map { $0 == tagColor.hex }
            .subscribe(onNext: { [unowned self] isPick in
                if isPick {
                    self.layer.shadowOpacity = 0.3
                } else {
                    self.layer.shadowOpacity = 0
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadow(radius: 10, color: .black, offset: .zero, opacity: 0)
    }
}


