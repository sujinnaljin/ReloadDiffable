//
//  ExpandableCell.swift
//  ReloadDiffable
//
//  Created by 강수진 on 2023/05/25.
//

import UIKit

protocol ExpandableCellDelegate: AnyObject {
    func expandableCell(_ cell: ExpandableCell, didSelectExpand isExpand: Bool)
}

class ExpandableCell: UICollectionViewCell {
    
    typealias DiffableSection = SectionType
    typealias DiffableItem = ItemType
   
    enum SectionType: Hashable {
        case item(sectionIndex: Int)
        case arrow
    }
    
    enum ItemType: Hashable {
        case item(data: String)
        case arrow(isExpand: Bool)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<DiffableSection, DiffableItem>!
    
    let apiData = ["hello", "world", "nice", "to", "meet", "you", "why", "it", "does", "not", "work?", "help!"]
    
    weak var delegate: ExpandableCellDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayout()
        registerCollectionView()
        configureDataSource()
        collectionView.backgroundColor = .yellow
    }
    
    
    func configure(isExpand: Bool) {
        applySnapshot(isExpand: isExpand)
    }
    
    private func registerCollectionView() {
        let itemNib = UINib(nibName: String(describing: "ItemCell"), bundle: .main)
        collectionView.register(itemNib, forCellWithReuseIdentifier: "ItemCell")
        let arrowNib = UINib(nibName: String(describing: "ArrowCell"), bundle: .main)
        collectionView.register(arrowNib, forCellWithReuseIdentifier: "ArrowCell")
    }
}

//MARK: - Layout
extension ExpandableCell {
    private func configureLayout() {
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionIdentifier = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch sectionIdentifier {
            case .item:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                return section
            default:
                let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
                let section = NSCollectionLayoutSection.list(using: configuration,
                                                                         layoutEnvironment: layoutEnvironment)
                return section
            }
        }
    }
}

//MARK: - Configure DataSource
extension ExpandableCell {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DiffableSection, DiffableItem>(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .item(let title):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
                cell.titleLabel.text = title
                return cell
            case .arrow(let isExpand):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArrowCell", for: indexPath) as! ArrowCell
                cell.delegate = self
                cell.expandButton.isSelected = isExpand
                return cell
            }
        }
    }
}

//MARK: - Apply Snapshot
extension ExpandableCell {
    private func applySnapshot(isExpand: Bool) {
        if isExpand {
            applyExpandSnapshots()
        }else {
            applyFoldSnapshots()
        }
    }
    
    private func applyExpandSnapshots() {
        let snapShot = makeSnapshot(titles: self.apiData,
                                    visibleItemSectionCount: 2,
                                    isExpand: true)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func applyFoldSnapshots() {
        let snapshot = makeSnapshot(titles: self.apiData,
                                    visibleItemSectionCount: 1,
                                    isExpand: false)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func makeSnapshot(titles: [String],
                              visibleItemSectionCount: Int,
                              isExpand: Bool) -> NSDiffableDataSourceSnapshot<DiffableSection, DiffableItem> {
        var snapshot = NSDiffableDataSourceSnapshot<DiffableSection, DiffableItem>()
      
        // append item sections
        Array(0..<visibleItemSectionCount)
            .forEach { sectionIndex in
                let section = SectionType.item(sectionIndex: sectionIndex)
                snapshot.appendSections([section])
                let items = titles.map {
                    let title = $0 + sectionIndex.description
                    return ItemType.item(data: title)
                }
                snapshot.appendItems(items,
                                     toSection: section)
            }
        
        // append expand section
        let arrowSection = SectionType.arrow
        let arrowItem = ItemType.arrow(isExpand: isExpand)
        snapshot.appendSections([arrowSection])
        snapshot.appendItems([arrowItem],
                             toSection: arrowSection)
        return snapshot
    }
}

extension ExpandableCell: ArrowCellDelegate {
    func didTapButton(isExpand: Bool) {
        delegate?.expandableCell(self, didSelectExpand: isExpand)
    }
}
