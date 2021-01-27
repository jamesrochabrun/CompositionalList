//
//  CustomLayout.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/18/21.
//

import UIKit
import CompositionalList

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
                section = .tilesSection(header: true)
            }
            return layoutEnvironment.isPortraitEnvironment ? section : NSCollectionLayoutSection.grid(5)
        }
    }
}
