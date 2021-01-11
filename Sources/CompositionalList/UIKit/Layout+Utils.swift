//
//  Layout+Utils.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/10/21.
//

import UIKit

/// Define a list of layout.
@available(iOS 13.0, *)
public extension NSCollectionLayoutEnvironment {
    
    var isPortraitEnvironment: Bool {
        container.contentSize.height > container.contentSize.width
    }
}

public extension UITraitCollection {
    
    var isRegularWidthRegularHeight: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
}

// MARK:- Helper Models
@available(iOS 13.0, *)
public enum ScrollAxis {
    case vertical
    case horizontal(UICollectionLayoutSectionOrthogonalScrollingBehavior)
}

public enum FlowDirection: CaseIterable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

@available(iOS 13.0, *)
public struct LayoutDimension {
    var itemWidth: CGFloat? = nil
    let itemInset: NSDirectionalEdgeInsets
    let sectionInset: NSDirectionalEdgeInsets
}

@available(iOS 13.0, *)
public extension LayoutDimension {
    
    init(width: CGFloat) {
        self.itemWidth = width
        self.itemInset = .zero
        self.sectionInset = .zero
    }
}

// MARK:- UICollectionViewLayout's
@available(iOS 13.0, *)
public extension UICollectionViewLayout {
    
    // Composed layout example.
    static func composedLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = NSCollectionLayoutSection.listWith(scrollingBehavior: .paging)
            default:
                section = NSCollectionLayoutSection.tilesSection(header: true, footer: false)
            }
            return layoutEnvironment.isPortraitEnvironment ? section : NSCollectionLayoutSection.grid(3)
        }
    }
}


// MARK:- NSCollectionLayoutSection
@available(iOS 13.0, *)
public extension NSCollectionLayoutSection {
    
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
    
    /// List iOS 13
    static func listWith(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
                         header: Bool = false,
                         footer: Bool = false) -> NSCollectionLayoutSection {
        // 2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        // 3
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
        // 4
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .estimated(250))
        // 5
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize,
                                                             subitems: [layoutItem])
            
        // 6
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        // 7
        layoutSection.orthogonalScrollingBehavior = scrollingBehavior
        
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)

        return layoutSection
    }
    
    /// Tiles
    static func tilesSection(itemInset: NSDirectionalEdgeInsets = .all(1.0),
                             header: Bool = false,
                             footer: Bool = false) -> NSCollectionLayoutSection {
        
        let groupsFraction: CGFloat = 5.0 // needs to be equal of nestedSubGroups count
        /// PART 1
        let firstGroup = NSCollectionLayoutGroup.mainContentTopLeadingWith(itemInset, fraction: groupsFraction)
        /// PART 2
        let secondGroup = NSCollectionLayoutGroup.mainContentTopTrailingWith(itemInset, fraction: groupsFraction)
        /// PART3
        let thirdGroup = NSCollectionLayoutGroup.mainContentBottomLeadingWith(itemInset, fraction: groupsFraction)
    
        let fourdGroup = NSCollectionLayoutGroup.mainContentBottomTrailingWith(itemInset, fraction: groupsFraction)
        
        let fifthGroup = NSCollectionLayoutGroup.mainContentVerticalRectangle(itemInset, fraction: groupsFraction, rectanglePosition: .topTrailing)
        
        /// FINAL GROUP
        let nestedSubGroups = [firstGroup, secondGroup, thirdGroup, fourdGroup, fifthGroup]
        let nestedSubGroupsCount = CGFloat(nestedSubGroups.count)
        
        let finalNestedGroup = NSCollectionLayoutGroup.vertical(
         layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalWidth(nestedSubGroupsCount)),
         subitems: nestedSubGroups)
        
        let section = NSCollectionLayoutSection(group: finalNestedGroup)
        section.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        return section
    }
    
    /// Grid layout
    static func grid(_ columns: Int,
                     contentInsets: NSDirectionalEdgeInsets = .all(0),
                     sectionInsets: NSDirectionalEdgeInsets = .all(0),
                     header: Bool = false,
                     footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        /// min line spacing and the min spearator
        item.contentInsets = contentInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1.0 / CGFloat(columns)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
        
        /// sections insets
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = sectionInsets
        
        section.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        
        return section
    }
    
    /// Layout with dimensions
    static func layoutWithDimension(dimension: LayoutDimension,
                                    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuousGroupLeadingBoundary,
                                    header: Bool = false,
                                    footer: Bool = false) -> NSCollectionLayoutSection {
        /// ideal for squares
        let width = dimension.itemWidth ?? 0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.absolute(width),
                                              heightDimension: NSCollectionLayoutDimension.fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        /// min line spacing and the min spearator
        item.contentInsets = dimension.itemInset
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(width),
                                                     heightDimension: .estimated(250))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [item])
        
        /// sections insets
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = scrollingBehavior
        
        section.contentInsets = dimension.sectionInset
        
        section.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)

        return section
    }
}

// MARK: Groups
@available(iOS 13.0, *)
public extension NSCollectionLayoutGroup {
    
    /// Returns a square full width aspect ratio 1:1
    static func fullSquareGroupWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = insets
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(CGFloat(1.0/fraction)))
        return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
    }
    
    /// Returns a Grid with a main content on the leading top area, a grid of 3 items on the bottom and a grid of to items in the trailing section
    static func mainContentTopLeadingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
       
        // Big leading content
        let mainContentLeadingItem = NSCollectionLayoutItem.mainItem
        mainContentLeadingItem.contentInsets = insets
    
        // 2 vertical groups of 2 items each.
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topTrailingGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal top group
        let nestedTopHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([mainContentLeadingItem, topTrailingGroup])

        ////  bottom group
        let bottomRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        bottomRegularItem.contentInsets = insets
        
        // Horizontal bottom group a row of 3 items
        let horizontalBottomGroup = NSCollectionLayoutGroup.horizontal3RegularItems(bottomRegularItem)
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [nestedTopHorizontalGroup, horizontalBottomGroup])
    }
    
    static func mainContentTopTrailingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topLeadingGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedTopHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([topLeadingGroup, trailingBigItem])
        
        ////  bottom Section
        let bottomRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        bottomRegularItem.contentInsets = insets
        
        let horizontalBottomGroup = NSCollectionLayoutGroup.horizontal3RegularItems(bottomRegularItem)
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [nestedTopHorizontalGroup, horizontalBottomGroup])
    }
    
    static func mainContentBottomTrailingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let topRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        topRegularItem.contentInsets = insets
        let horizontalTopGroup = NSCollectionLayoutGroup.horizontal3RegularItems(topRegularItem)
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topLeadingVerticalGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedBottomHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([topLeadingVerticalGroup, trailingBigItem])
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [horizontalTopGroup, nestedBottomHorizontalGroup])
    }
    
    static func mainContentBottomLeadingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let topRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        topRegularItem.contentInsets = insets
        let horizontalTopGroup = NSCollectionLayoutGroup.horizontal3RegularItems(topRegularItem)
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topTrailingVerticalGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedBottomHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([trailingBigItem, topTrailingVerticalGroup])
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [horizontalTopGroup, nestedBottomHorizontalGroup])
    }
    
    /// Vertical rectangular as main content
    static func mainContentVerticalRectangle(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat, rectanglePosition: FlowDirection) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let rectangularVerticalitem = NSCollectionLayoutItem.verticalRectangularItem
        rectangularVerticalitem.contentInsets = insets
        
        // Vertical Group A items
        let vertircalRegularItemA = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItemA.contentInsets = insets
        let topVertircalRegularItemA = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItemA)
        
        // Vertical Group B items
        let vertircalRegularItemB = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItemB.contentInsets = insets
        let topVertircalRegularItemB = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItemB)
        
        // Horizontal group main content + vertical items position
        var nestedMainGroupItems: [NSCollectionLayoutItem] = []
        switch rectanglePosition {
        case .bottomLeading, .topLeading:
            nestedMainGroupItems.append(contentsOf: [rectangularVerticalitem, topVertircalRegularItemA, topVertircalRegularItemB])
        case .bottomTrailing, .topTrailing:
            nestedMainGroupItems.append(contentsOf: [topVertircalRegularItemA, topVertircalRegularItemB, rectangularVerticalitem])
        }
        let nestedMainContentGroup = NSCollectionLayoutGroup.nestedHorizontalGroup(nestedMainGroupItems)
        
        /// 3 horizontal items group
        let horizontalRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        horizontalRegularItem.contentInsets = insets
        let horizontalThreeItemsGroup = NSCollectionLayoutGroup.horizontal3RegularItems(horizontalRegularItem)
        
        /// Final Main group
        var group: [NSCollectionLayoutItem] = []
        switch rectanglePosition {
        case .bottomLeading, .bottomTrailing:
            group.append(contentsOf: [horizontalThreeItemsGroup, nestedMainContentGroup])
        case .topLeading, .topTrailing:
            group.append(contentsOf: [nestedMainContentGroup, horizontalThreeItemsGroup])
        }
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: group)
    }
}


// MARK:- Single item
@available(iOS 13.0, *)
public extension NSCollectionLayoutItem {
    
    static var mainItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3),
                                           heightDimension: .fractionalHeight(1.0)))
    }
    
    static var verticalRegularItem: NSCollectionLayoutItem {
         NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.5)))
    }
    
    static var horizontalRegularItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                           heightDimension: .fractionalHeight(1.0)))
    }
    
    static var verticalRectangularItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                               heightDimension: .fractionalHeight(1.0)))
    }
}

// MARK:- Simple groups
@available(iOS 13.0, *)
public extension NSCollectionLayoutGroup {
    
    static func vertical2RegularItems(_ item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                           heightDimension: .fractionalHeight(1.0)),
        subitem: item, count: 2)
    }

    static func nestedHorizontalGroup(_ items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(2/3)),
        subitems: items)
    }
    
    static func horizontal3RegularItems(_ item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(1/3)),
        subitem: item, count: 3)
    }
}

@available(iOS 13.0, *)
public extension NSDirectionalEdgeInsets {
    
    static func all(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: value, leading: value, bottom: value, trailing: value)
    }
    static var zero: Self { .all(0) }
}

public extension UIEdgeInsets {
    
    static func all(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: value, bottom: value, right: value)
    }
    
    static var zero: Self { .all(0) }
}






