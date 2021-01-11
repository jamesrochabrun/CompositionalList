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
 - `HeaderFooterView` must conform to `View`, represents a header or a footer/
 -
 */
@available(iOS 13, *)
public struct CompositionalList<ViewModel: SectionIdentifierViewModel,
                         RowView: View,
                         HeaderFooterView: View> {
        
    public typealias Diff = DiffCollectionView<ViewModel, RowView, HeaderFooterView>

    @Environment(\.layout) var customLayout

    let itemsPerSection: [ViewModel]
    var parent: UIViewController?
    let cellProvider: Diff.CellProvider
    
    private (set)var headerProvider: Diff.HeaderFooterProvider? = nil
    
    public init(_ itemsPerSection: [ViewModel],
         parent: UIViewController? = nil,
         cellProvider: @escaping Diff.CellProvider) {
        
        self.itemsPerSection = itemsPerSection
        self.parent = parent
        self.cellProvider = cellProvider
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject {
    
        fileprivate let list: CompositionalList
        fileprivate let itemsPerSection: [ViewModel]
        fileprivate let cellProvider: Diff.CellProvider
        fileprivate var parent: UIViewController?
        
        fileprivate let layout: UICollectionViewLayout
        fileprivate let headerProvider: Diff.HeaderFooterProvider?
        
        init(_ list: CompositionalList) {
            
            self.list = list
            self.itemsPerSection = list.itemsPerSection
            self.layout = list.customLayout
            self.cellProvider = list.cellProvider
            self.parent = list.parent
            self.headerProvider = list.headerProvider
        }
    }
}

@available(iOS 13, *)
extension CompositionalList: UIViewRepresentable {
    
    public func updateUIView(_ uiView: Diff, context: Context) {
        uiView.applySnapshotWith(context.coordinator.itemsPerSection)
    }
    
    public func makeUIView(context: Context) -> Diff {
        Diff(layout: context.coordinator.layout,
             parent: context.coordinator.parent,
             context.coordinator.cellProvider,
             context.coordinator.headerProvider)
    }
}

@available(iOS 13, *)
extension CompositionalList {
    
    public func sectionHeader(_ header: @escaping Diff.HeaderFooterProvider) -> Self {
        var `self` = self
        `self`.headerProvider = header
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


