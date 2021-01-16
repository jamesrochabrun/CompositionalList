//
//  DiffCollectionView.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/10/21.
//

import UIKit
import SwiftUI

/**
 Protocol that represents a section in a collectionView data source.
 */
public protocol SectionIdentifierViewModel {
    associatedtype SectionIdentifier: Hashable
    associatedtype CellIdentifier: Hashable
    var sectionIdentifier: SectionIdentifier { get }
    var cellIdentifiers: [CellIdentifier] { get }
}

/// Helper
public struct GenericSectionIdentifierViewModel<SectionIdentifier: Hashable, CellIdentifier: Hashable>: SectionIdentifierViewModel {
    public var sectionIdentifier: SectionIdentifier? = nil
    public var cellIdentifiers: [CellIdentifier]
}

@available(iOS 13, *)
public final class DiffCollectionView<ViewModel: SectionIdentifierViewModel,
                                      RowView: View,
                                      HeaderFooterView: View>: UIView, UICollectionViewDelegate {
    
    // MARK:- Private
    private (set)var collectionView: UICollectionView! // if not initilaized, lets crash. 🤷🏽‍♂️
    private typealias DiffDataSource = UICollectionViewDiffableDataSource<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
    private var dataSource: DiffDataSource?
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
    private var currentSnapshot: Snapshot?
    
    // Used only if this class is used as an UIKit view.
    private weak var parent: UIViewController?
    
    // MARK:- Public
    public typealias CellProvider = (ViewModel.CellIdentifier, IndexPath) -> RowView
    public typealias HeaderFooterProvider = (ViewModel.SectionIdentifier, String, IndexPath) -> HeaderFooterView?
    public typealias SelectedContentAtIndexPath = ((ViewModel.CellIdentifier, IndexPath) -> Void)
    public var selectedContentAtIndexPath: SelectedContentAtIndexPath?
    
    // MARK:- Life Cycle
    convenience init(layout: UICollectionViewLayout,
                     parent: UIViewController?,
                     _ cellProvider: @escaping CellProvider,
                     _ headerFooterProvider: HeaderFooterProvider?) {
        self.init()
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WrapperViewCell<RowView>.self)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionFooter)
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        collectionView.collectionViewLayout = layout
        configureDataSource(cellProvider)
        if let headerFooterProvider = headerFooterProvider {
            assignHedearFooter(headerFooterProvider)
        }
        self.parent = parent
    }
    
    // MARK:- DataSource Configuration
    private func configureDataSource(_ cellProvider: @escaping CellProvider) {
        
        dataSource = DiffDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, model in
            let cell: WrapperViewCell<RowView> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            let cellView = cellProvider(model, indexPath)
            cell.setupWith(cellView, parent: self?.parent)
            return cell
        }
    }
    
    // MARK:- ViewModel injection and snapshot
    public func applySnapshotWith(_ itemsPerSection: [ViewModel]) {
        currentSnapshot = Snapshot()
        guard var currentSnapshot = currentSnapshot else { return }
        currentSnapshot.appendSections(itemsPerSection.map { $0.sectionIdentifier })
        itemsPerSection.forEach { currentSnapshot.appendItems($0.cellIdentifiers, toSection: $0.sectionIdentifier) }
        dataSource?.apply(currentSnapshot)
    }
    
    private func assignHedearFooter(_ headerFooterProvider: @escaping HeaderFooterProvider) {
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let header: WrapperCollectionReusableView<HeaderFooterView> = collectionView.dequeueSuplementaryView(of: kind, at: indexPath)
            if let sectionIdentifier = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section],
               let view = headerFooterProvider(sectionIdentifier, kind, indexPath) {
                header.setupWith(view, parent: self?.parent)
            }
            return header
        }
    }
    
    // MARK:- UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = dataSource?.itemIdentifier(for: indexPath) else { return }
        selectedContentAtIndexPath?(viewModel, indexPath)
    }
}

@available(iOS 13.0, *)
// MARK:- Helper
extension NSDiffableDataSourceSnapshot {
    
    mutating func deleteItems(_ items: [ItemIdentifierType], at section: Int) {
        
        deleteItems(items)
        let sectionIdentifier = sectionIdentifiers[section]
        guard numberOfItems(inSection: sectionIdentifier) == 0 else { return }
        deleteSections([sectionIdentifier])
    }
}
