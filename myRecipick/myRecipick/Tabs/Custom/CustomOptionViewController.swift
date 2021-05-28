//
//  CustomOptionViewController.swift
//  myRecipick
//
//  Created by Min on 2021/05/19.
//  Copyright © 2021 depromeet. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class CustomOptionViewController: UIViewController, ClassIdentifiable {

    static func makeViewController(menu: MenuModel) -> CustomOptionViewController {
        let vm = CustomOptionViewModel(menu: menu)
        let vc = CustomOptionViewController(nibName: self.identifier, bundle: nil)
        vc.viewModel = vm
        return vc
    }
    
    @IBOutlet weak var navigationView: CustomNavigationView!
    @IBOutlet weak var tableTopView: UIView!
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var resetView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    lazy var dataSource = OptionDatasource(collectionView: collectionView) { [weak self] list in
        self?.updateSnapshot(list: list)
    } cellSelectClosure: { [weak self] item in
        self?.showInfo(item: item)
    }
    
    private var viewModel: CustomOptionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationView()
        initCollectionView()
        initTableTopView()
        initTableBottomView()
        bind()
        viewModel.fetchOption()
    }
    
    private func bind() {
        viewModel.optionListObservable
            .bind(onNext: { [weak self] data in
                self?.updateSnapshot(list: data)
            }).disposed(by: disposeBag)
    }
    
    private func initNavigationView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationView.setTitle(viewModel.menu?.name ?? "")
        navigationView.setLeftButtonImage(Images.iconsNavigation24ArrowLeft.name)
        navigationView.leftButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        navigationView.setRightButtonImage(Images.iconClose.name)
        navigationView.rightButton.addTarget(self, action: #selector(popToRootView(_:)), for: .touchUpInside)
    }
    
    private func initTableTopView() {
        tableTopView.backgroundColor = Colors.grayScaleEE.color
        optionImageView.kf.setImage(with: URL(string: viewModel.menu?.image ?? ""),
                                   placeholder: nil,
                                   options: [.cacheMemoryOnly],
                                   completionHandler: { [weak self] _ in
                                    self?.optionImageView.fadeIn(duration: 0.1, completeHandler: nil)
                                   })
        resetView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        resetButton.setTitle("초기화", for: .normal)
        resetButton.setTitleColor(Colors.grayScale66.color, for: .normal)
        resetButton.titleLabel?.font = .myRecipickFont(.button)
    }
    
    private func initCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.register(UINib(nibName: CustomOptionTitleCell.identifier, bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: CustomOptionTitleCell.identifier)
        collectionView.register(UINib(nibName: CustomOptionSubTitleCell.identifier, bundle: nil), forCellWithReuseIdentifier: CustomOptionSubTitleCell.identifier)
        collectionView.register(UINib(nibName: CustomOptionAdditionalCell.identifier, bundle: nil), forCellWithReuseIdentifier: CustomOptionAdditionalCell.identifier)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        dataSource.baseVC = self
    }
    
    private func initTableBottomView() {
        doneButton.setTitle("커스텀 완료", for: .normal)
        doneButton.setTitleColor(Colors.white.color, for: .normal)
        doneButton.setBackgroundColor(Colors.primaryNormal.color, for: .normal)
        doneButton.setBackgroundColor(Colors.primaryLight.color, for: .highlighted)
        doneButton.roundCorner(radius: 4)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layoutSize = NSCollectionLayoutSize.init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        
        let section = NSCollectionLayoutSection(group: .vertical(layoutSize: layoutSize,
                                                                 subitems: [.init(layoutSize: layoutSize)] ) )
        
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 0
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        section.boundarySupplementaryItems = [header]

        return .init(section: section)
    }
    
    private func updateSnapshot(list: [OptionSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<OptionSection, OptionItem>()
        snapshot.appendSections(list)
        list.forEach {
            if $0.isExpanded {
                snapshot.appendItems($0.items, toSection: $0)
            }
        }
        apply(snapshot: snapshot)
    }
    
    private func apply(snapshot: NSDiffableDataSourceSnapshot<OptionSection, OptionItem>) {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showInfo(item: OptionModel) {
        
    }
    
}

extension CustomOptionViewController {
    
    @objc
    private func dismiss(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func popToRootView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func resetAll(_ sender: UIButton) {
        print("reset")
    }
}

class OptionDatasource: UICollectionViewDiffableDataSource<OptionSection, OptionItem>, UICollectionViewDelegate {
        
    var headerSelectClosure: (([OptionSection]) -> Void)?
    var cellSelectClosure: ((OptionModel) -> Void)?
    
    weak var baseVC: UIViewController?
    
    init(collectionView: UICollectionView,
         headerSelectClosure: (([OptionSection]) -> Void)?,
         cellSelectClosure: ((OptionModel) -> Void)?) {
        super.init(collectionView: collectionView) { _, _, _ in nil }
        self.headerSelectClosure = headerSelectClosure
        self.cellSelectClosure = cellSelectClosure
        collectionView.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemIdentifier(for: indexPath)
        switch item?.type {
        case .option:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomOptionSubTitleCell.identifier, for: indexPath) as? CustomOptionSubTitleCell,
                  let item = self.itemIdentifier(for: indexPath) else { fatalError() }
            
            if item.isSelected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
            }
            cell.bind(item: item.item)
            cell.vc = baseVC
            
            return cell
        case .additional:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomOptionAdditionalCell.identifier, for: indexPath) as? CustomOptionAdditionalCell else { fatalError() }
            return cell
        default:
            return .init()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "header" {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomOptionTitleCell.identifier, for: indexPath) as? CustomOptionTitleCell else { fatalError("정의되지 않은 헤더입니다.") }
            let item = self.snapshot().sectionIdentifiers[indexPath.section]
            header.section = item
            header.tapObservable.subscribe(onNext: { [weak item, weak self] in
                guard let item = item, let self = self else { return }
                self.snapshot().sectionIdentifiers.forEach { $0.isExpanded = false }
                item.isExpanded = true
                self.headerSelectClosure?(self.snapshot().sectionIdentifiers)
            }).disposed(by: header.disposeBag)
            return header
        }
        return .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.itemIdentifier(for: indexPath)
        item?.isSelected = true
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let item = self.itemIdentifier(for: indexPath)
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let section = self.snapshot().sectionIdentifiers[indexPath.section]
        if section.isSingleSelection {
            section.items
                .enumerated()
                .forEach { (offset, item) in
                item.isSelected = false
                collectionView.deselectItem(at: IndexPath(item: offset, section: indexPath.section), animated: true)
            }
        }
        return true
    }
    
}

