//
//  CompositionalList.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/10/21.
//


import SwiftUI
import UIKit

/// `UIViewRepresentable` object that takes a `View` and a `Model` to render items in a list, it takes a `UICollectionViewLayout`  from an environment object.

/**
 - `ViewModel` must conform to `SectionIdentifierViewModel` `
 - `RowView` must conform to `View`, represents a cell.
 - `HeaderFooterView` must conform to `View`, represents a header or a footer. Dev must provide a view to satisfy the generic parameter, if a header
 is not needed return a `Spacer` with height of `0`
 - `SelectionProvider` provides the view model associated with the selected cell. This is optional
 -
 */
@available(iOS 13, *)
public struct CompositionalList<ViewModel: SectionIdentifierViewModel,
                         RowView: View,
                         HeaderFooterView: View> {
        
    public typealias Diff = DiffCollectionView<ViewModel, RowView, HeaderFooterView>
    public typealias SelectionProvider = ((ViewModel.CellIdentifier) -> Void)

    @Environment(\.layout) var customLayout

    var itemsPerSection: [ViewModel]
    let cellProvider: Diff.CellProvider
    var selectionProvider: SelectionProvider?

    private (set)var headerProvider: Diff.HeaderFooterProvider? = nil
    
    public init(_ items: [ViewModel],
                @ViewBuilder cellProvider: @escaping Diff.CellProvider) {
        self.cellProvider = cellProvider
        self.itemsPerSection = items
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, UICollectionViewDelegate {
    
        fileprivate let list: CompositionalList
        fileprivate var itemsPerSection: [ViewModel]
        fileprivate let cellProvider: Diff.CellProvider
        
        fileprivate let layout: UICollectionViewLayout
        fileprivate let headerProvider: Diff.HeaderFooterProvider?
        fileprivate let selectionProvider: SelectionProvider?
        
        init(_ list: CompositionalList) {

            self.list = list
            self.layout = list.customLayout
            self.cellProvider = list.cellProvider
            self.headerProvider = list.headerProvider
            self.itemsPerSection = list.itemsPerSection
            self.selectionProvider = list.selectionProvider
        }
        
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let sectionIdentifier = itemsPerSection[indexPath.section]
            let model = sectionIdentifier.cellIdentifiers[indexPath.item]
            selectionProvider?(model)
        }
    }
}

@available(iOS 13, *)
extension CompositionalList: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> Diff {
        Diff(layout: context.coordinator.layout,
             collectionViewDelegate: context.coordinator,
             context.coordinator.cellProvider,
             context.coordinator.headerProvider)
    }
    
    public func updateUIViewController(_ uiViewController: Diff, context: Context) {
        uiViewController.applySnapshotWith(context.coordinator.itemsPerSection)
    }
}

@available(iOS 13, *)
extension CompositionalList {
    
    public func sectionHeader(_ header: @escaping Diff.HeaderFooterProvider) -> Self {
        var `self` = self
        `self`.headerProvider = header
        return `self`
    }
    
    public func selectedItem(_ selectionProvider: SelectionProvider?) -> Self {
        var `self` = self
        `self`.selectionProvider = selectionProvider
        return `self`
    }
}

///// Environment
@available(iOS 13, *)
public struct Layout: EnvironmentKey {
    public static var defaultValue: UICollectionViewLayout = UICollectionViewLayout()
}

@available(iOS 13, *)
extension EnvironmentValues {
    var layout: UICollectionViewLayout {
        get { self[Layout.self] }
        set { self[Layout.self] = newValue }
    }
}

@available(iOS 13, *)
public extension CompositionalList {
    func customLayout(_ layout: UICollectionViewLayout) -> some View {
        environment(\.layout, layout)
    }
}


