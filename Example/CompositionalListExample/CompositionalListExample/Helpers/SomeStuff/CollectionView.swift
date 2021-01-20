//
//  CollectionView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/19/21.
//

import SwiftUI
import CompositionalList


struct CollectionView<ViewModel: SectionIdentifierViewModel, RowView: View>: UIViewControllerRepresentable {
    
    
    typealias Diff = CollectionViewController<ViewModel, RowView>
    typealias Snap = NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
    
    // MARK: - Properties
    let layout: UICollectionViewLayout
    let items: [ViewModel]
    
    // MARK: - Actions
    let snapshot: (() -> Snap)?
    let content: (_ indexPath: IndexPath, _ item: ViewModel.CellIdentifier) -> RowView
    
    // MARK: - Init
    init(layout: UICollectionViewLayout,
         items: [ViewModel],
         snapshot: (() -> NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>)? = nil,
         @ViewBuilder content: @escaping (_ indexPath: IndexPath, _ item: ViewModel.CellIdentifier) -> RowView) {
        self.layout = layout
        self.items = items
        self.snapshot = snapshot
        self.content = content
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> Diff {
        
        let controller = Diff()
        controller.layout = self.layout
        controller.content = content
        controller.snapshotForCurrentState = {
            
            if let snapshot = self.snapshot {
                return snapshot()
            }
            var snapshot = Snap()
            snapshot.appendSections(items.map { $0.sectionIdentifier })
            items.forEach { snapshot.appendItems($0.cellIdentifiers, toSection: $0.sectionIdentifier) }
            dump(items)
            return snapshot
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: Diff, context: Context) {
        uiViewController.collectionView?.delegate = context.coordinator
        uiViewController.updateUI()
    }
    
    
    class Coordinator: NSObject, UICollectionViewDelegate {
        
        // MARK: - Properties
        let parent: CollectionView
        
        // MARK: - Init
        init(_ parent: CollectionView) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Did select item at \(indexPath)")
        }
    }
}


class CollectionViewController<ViewModel: SectionIdentifierViewModel, RowView>: UIViewController, UICollectionViewDelegate where RowView: View {

    var layout: UICollectionViewLayout! = nil
    var snapshotForCurrentState: (() -> NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>)! = nil
    var content: ((_ indexPath: IndexPath, _ item: ViewModel.CellIdentifier) -> RowView)! = nil

    
    private typealias DiffDataSource = UICollectionViewDiffableDataSource<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
    private var dataSource: DiffDataSource?
//    private typealias Snapshot = NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier>
//    private var currentSnapshot: Snapshot?
    private (set)var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        ///collectionView.dataSource = dataSource
        collectionView.delegate = self
        configureDataSource()
    }
}

extension CollectionViewController {

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .red
        collectionView.register(WrapperViewCell<RowView>.self)
        view.addSubview(collectionView)
    }


    private func configureDataSource() {

        // load initial data
//        let snapshot : NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier> = snapshotForCurrentState()
//        dataSource.apply(snapshot, animatingDifferences: false)
        
        dataSource = DiffDataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, model in
            let cell: WrapperViewCell<RowView> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.setupWith(self.content(indexPath, model), parent: self)
            return cell
        }
    }

    private func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, item: ViewModel.CellIdentifier) -> UICollectionViewCell? {
        let cell: WrapperViewCell<RowView> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        return cell
    }
}

extension CollectionViewController {

    func updateUI() {
        let snapshot : NSDiffableDataSourceSnapshot<ViewModel.SectionIdentifier, ViewModel.CellIdentifier> = snapshotForCurrentState()
        dataSource?.apply(snapshot)
        //dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
