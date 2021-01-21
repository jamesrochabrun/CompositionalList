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
                                     HeaderFooterView: View>: UIViewController {
   
   // MARK:- Private
   private (set)var collectionView: UICollectionView! // if not initilaized, lets crash. 🤷🏽‍♂️
   private typealias DiffDataSource = UICollectionViewDiffableDataSource<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
   private var dataSource: DiffDataSource?
   private typealias Snapshot = NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
   private var currentSnapshot: Snapshot?
   
   // MARK:- Public
   public typealias CellProvider = (ViewModel.CellIdentifier, IndexPath) -> RowView
   public typealias HeaderFooterProvider = (ViewModel.SectionIdentifier, String, IndexPath) -> HeaderFooterView?
   public typealias SelectedContentAtIndexPath = ((ViewModel.CellIdentifier, IndexPath) -> Void)
   public var selectedContentAtIndexPath: SelectedContentAtIndexPath?
   
    // MARK:- Life Cycle
    convenience init(layout: UICollectionViewLayout,
                     collectionViewDelegate: UICollectionViewDelegate,
                     @ViewBuilder _ cellProvider: @escaping CellProvider,
                     _ headerFooterProvider: HeaderFooterProvider?) {
        self.init()
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WrapperViewCell<RowView>.self)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionFooter)
        collectionView.delegate = collectionViewDelegate
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        configureDataSource(cellProvider)
        if let headerFooterProvider = headerFooterProvider {
            assignHedearFooter(headerFooterProvider)
        }
    }
   
   // MARK:- DataSource Configuration
   private func configureDataSource(_ cellProvider: @escaping CellProvider) {
       
       dataSource = DiffDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, model in
           let cell: WrapperViewCell<RowView> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
           let cellView = cellProvider(model, indexPath)
           cell.setupWith(cellView, parent: self)
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
               header.setupWith(view, parent: self)
           }
           return header
       }
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
