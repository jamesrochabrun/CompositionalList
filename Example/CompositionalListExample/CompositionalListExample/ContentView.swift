//
//  ContentView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

struct Colle: View {
    
    @ObservedObject private var remote = ItunesRemote()

    var body: some View {
        VStack {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(SectionIdentifierExample.allCases, id: \.self) { app in
                        Text(app.rawValue)
                            .onTapGesture {
                                switch app {
                                case .comingSoon:
                                    remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
                                case .new:
                                    remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
                                default:
                                    remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
                                }
                            }
                        Divider()
                    }
                }
                HStack {
                    List(remote.feedItems.first?.cellIdentifiers ?? [], id: \.id) { app in
                        Text(app.kind)
                        Divider()
                    }
                }
            }.frame(height: 100)
        }
        NavigationView {
            if remote.feedItems.isEmpty {
                ActivityIndicator()
            } else {
                CollectionView(layout: .composed(), items: remote.feedItems) { indexPath, model in
                    NavigationLink(destination: ItunesFeedItemDetailView(viewModel: model)) {
                        Group {
                            switch indexPath.section {
                            case 0, 2, 3:
                                TileInfo(artworkViewModel: model)
                            case 1:
                                ListItem(artworkViewModel: model)
                            default:
                                ArtWork(artworkViewModel: model)
                            }
                        }
                        
                    }
                }
            }
        }
        .onAppear() {
            remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
        }
    }
}

struct ContentView: View {

    @ObservedObject private var remote = ItunesRemote()
    @State var selectedItem: FeedItemViewModel?
    
    var body: some View {
//        VStack {
//            ScrollView (.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(SectionIdentifierExample.allCases, id: \.self) { app in
//                        Text(app.rawValue)
//                            .onTapGesture {
//                                switch app {
//                                case .comingSoon:
//                                    remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
//                                case .new:
//                                    remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
//                                default:
//                                    remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
//                                }
//                            }
//                        Divider()
//                    }
//                }
//                HStack {
//                    List(remote.feedItems.first?.cellIdentifiers ?? [], id: \.id) { app in
//                        Text(app.kind)
//                        Divider()
//                    }
//                }
//            }.frame(height: 100)
//        }
        NavigationView {
            if remote.feedItems.isEmpty {
                ActivityIndicator()
            } else {
                
//                List(remote.feedItems.first!.cellIdentifiers, id: \.self, selection: $selectedItem) {  v in
//                    TileInfo(artworkViewModel: v)
//                }
                
                CompositionalList(remote.feedItems) { model, indexPath in
                    Group {
                        switch indexPath.section {
                        case 0, 2, 3:
                            TileInfo(artworkViewModel: model)
                        case 1:
                            ListItem(artworkViewModel: model)
                        default:
                            ArtWork(artworkViewModel: model)
                        }
                    }
                    // step 3: provide a `sectionHeader` can be a Spacer with height 0
                }.sectionHeader { sectionIdentifier, kind, indexPath in
                    HStack {
                        Text(sectionIdentifier?.rawValue ??  "")
                            .bold()
                            .font(.title)
                        Spacer()
                    }
                    .padding()
                }.onDetail { item in
                    self.selectedItem = item
                }
                // step 4: provide a `UICollectionViewLayout`
                .customLayout(.composed())
                .sheet(item: $selectedItem) { item in
                    ItunesFeedItemDetailView(viewModel: item)
                }
            }
        }
        .onAppear {
            // remote.fetchItems(.appleMusic(feedType: .topSongs(genre: .all), limit: 200))
            remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
            //  remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
            // remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
            //   remote.fetchItems(.podcast(feedType: .top(genre: .all), limit: 200))
            //   remote.fetchItems(.itunesMusic(feedType: .topSongs(genre: .all), limit: 200))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


@available(iOS 13, *)
public struct CompositionalList1<ViewModel: SectionIdentifierViewModel,
                         RowView: View,
                         HeaderFooterView: View> {
        
    public typealias Diff = DiffCollectionView1<ViewModel, RowView, HeaderFooterView>

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
    
        fileprivate let list: CompositionalList1
        fileprivate var itemsPerSection: [ViewModel]
        fileprivate let cellProvider: Diff.CellProvider
        
        fileprivate let layout: UICollectionViewLayout
        fileprivate let headerProvider: Diff.HeaderFooterProvider?
        fileprivate let selectionProvider: SelectionProvider?

        init(_ list: CompositionalList1) {

            self.list = list
            self.layout = list.customLayout
            self.cellProvider = list.cellProvider
            self.headerProvider = list.headerProvider
            self.itemsPerSection = list.itemsPerSection
            self.selectionProvider = list.selectionProvider
        }
        
        // Not used but kept for testing purposes
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let sectionIdentifier = itemsPerSection[indexPath.section]
            let model = sectionIdentifier.cellIdentifiers[indexPath.item]
            selectionProvider?(model)
        }
    }
}

@available(iOS 13, *)
extension CompositionalList1: UIViewControllerRepresentable {
    
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
extension CompositionalList1 {
    
    public func sectionHeader(_ header: @escaping Diff.HeaderFooterProvider) -> Self {
        var `self` = self
        `self`.headerProvider = header
        return `self`
    }
    
    public func onDetail(_ selectionProvider: SelectionProvider?) -> Self {
        var `self` = self
        `self`.selectionProvider = selectionProvider
        return `self`
    }
}
///// Environment
@available(iOS 13, *)
public struct Layout1: EnvironmentKey {
    public static var defaultValue: UICollectionViewLayout = UICollectionViewLayout()
}

@available(iOS 13, *)
extension EnvironmentValues {
    var layout: UICollectionViewLayout {
        get { self[Layout1.self] }
        set { self[Layout1.self] = newValue }
    }
}

@available(iOS 13, *)
public extension CompositionalList1 {
    func customLayout(_ layout: UICollectionViewLayout) -> some View {
        environment(\.layout, layout)
    }
}


public protocol SectionIdentifierViewModel {
   associatedtype SectionIdentifier: Hashable
   associatedtype CellIdentifier: Hashable
   var sectionIdentifier: SectionIdentifier { get }
   var cellIdentifiers: [CellIdentifier] { get }
}



@available(iOS 13, *)
public final class DiffCollectionView1<ViewModel: SectionIdentifierViewModel,
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

