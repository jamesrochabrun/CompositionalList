//
//  CustomLayout.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/18/21.
//

import UIKit

public extension UICollectionViewLayout {
    
    // Composed layout example.
    static func composed() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = .horizontalTiles(scrollingBehavior: .continuousGroupLeadingBoundary, groupSize: .init(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.55)), header: true)
            case 1:
                section = .groupedList(header: true)
            case 2:
                section = .horizontalTiles(scrollingBehavior: .continuousGroupLeadingBoundary, groupSize: .init(widthDimension: .fractionalWidth(0.92), heightDimension: .fractionalWidth(0.95)), header: true)
            case 3:
                section = .verticalGroupTiles(scrollingBehavior: .continuousGroupLeadingBoundary, groupSize: .init(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(1.1)), header: true)
            default:
                section = .tilesSection(header: true, footer: false)
            }
            return layoutEnvironment.isPortraitEnvironment ? section : NSCollectionLayoutSection.grid(5)
        }
    }
}

extension NSCollectionLayoutSection {
    
    private static func supplementaryItems(header: Bool, footer: Bool) -> [NSCollectionLayoutBoundarySupplementaryItem] {
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(200)) // <- estimated will dynamically adjust to less height if needed.
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind:  UICollectionView.elementKindSectionFooter, alignment: .bottom)
        var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
        if header {
            supplementaryItems.append(sectionHeader)
        }
        if footer {
            supplementaryItems.append(sectionFooter)
        }
        return supplementaryItems
    }
    
    static func horizontalTiles(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuousGroupLeadingBoundary,
                                groupSize: NSCollectionLayoutSize,
                                header: Bool = false,
                                footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])
        let layoutSection: NSCollectionLayoutSection = .init(group: group)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        return layoutSection
    }
    
    static func groupedList(rows: CGFloat = 4,
                            itemHeight: CGFloat = 50,
                            scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuousGroupLeadingBoundary,
                            header: Bool = false,
                            footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(itemHeight))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 0, bottom: 5, trailing: 0)
        
        let layoutGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(0.92),
                              heightDimension: .absolute(itemHeight * rows)),
            subitem: layoutItem, count: Int(rows))
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        
        return layoutSection
    }
    
    static func verticalGroupTiles(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuousGroupLeadingBoundary,
                                   groupSize: NSCollectionLayoutSize,
                                   header: Bool = false,
                                   footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: layoutItem, count: 2)
        let layoutSection: NSCollectionLayoutSection = .init(group: group)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        return layoutSection
    }
}
