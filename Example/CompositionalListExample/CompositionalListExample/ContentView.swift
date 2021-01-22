//
//  ContentView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

struct Tab: View {
    
    @ObservedObject private var remote = ItunesRemote()
    var navigationBarTitle: Text {
        Text(Itunes.ItunesFeedKind(kind: remote.feedItems.first?.cellIdentifiers.first?.kind ?? "")?.title ?? "Home")
    }
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Itunes.ItunesFeedKind.allCases, id: \.self) { kind in
                            Text(kind.title)
                                .padding()
                                .foregroundColor(.white)
                                .border(Color.white)
                                .padding(.horizontal, 5)
                                .onTapGesture {
                                    switch kind {
                                    case .music:
                                        remote.fetchItems(.appleMusic(feedType: .topSongs(genre: .all), limit: 200))
                                    case .apps:
                                        remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
                                    case .books:
                                        remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
                                    case .tvShows:
                                        remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
                                    case .musicVideos:
                                        remote.fetchItems(.musicVideos(feedType: .top(genre: .all), limit: 200))
                                    case .movies:
                                        remote.fetchItems(.movies(feedType: .top(genre: .all), limit: 200))
                                    case .podcast:
                                        remote.fetchItems(.podcast(feedType: .top(genre: .all), limit: 200))
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                //                .frame(height: 100)
                ContentView(items: $remote.feedItems, selectedItem: nil)
            }
            .navigationBarTitle(navigationBarTitle)
        }
        .onAppear {
            remote.fetchItems(.appleMusic(feedType: .topSongs(genre: .all), limit: 200))
            // remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
            // remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
            // remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
            // remote.fetchItems(.podcast(feedType: .top(genre: .all), limit: 200))
            // remote.fetchItems(.itunesMusic(feedType: .topSongs(genre: .all), limit: 200))
            // remote.fetchItems(.movies(feedType: .top(genre: .all), limit: 200))
            //            remote.fetchItems(.musicVideos(feedType: .top(genre: .all), limit: 200))
        }
    }
}

struct ContentView: View {
    
    //    @ObservedObject private var remote = ItunesRemote()
    @Binding var items: [GenericSectionIdentifierViewModel<SectionIdentifierExample, FeedItemViewModel>]
    @State var selectedItem: FeedItemViewModel?
    
    var body: some View {
        if items.isEmpty {
            ActivityIndicator()
        } else {
            CompositionalList1($items) { model, indexPath in
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
            }.sectionHeader { sectionIdentifier, kind, indexPath in
                HStack {
                    Text(sectionIdentifier?.rawValue ??  "")
                        .bold()
                        .font(.title)
                    Spacer()
                }
                .padding()
            }
            .selectedItem {
                selectedItem = $0
            }
            .customLayout(.composed())
            .sheet(item: $selectedItem) { item in
                ItunesFeedItemDetailView(viewModel: item)
            }
        }
    }
}

@available(iOS 13, *)
public struct CompositionalList1<ViewModel: SectionIdentifierViewModel,
                         RowView: View,
                         HeaderFooterView: View> {
        
    public typealias Diff = DiffCollectionView<ViewModel, RowView, HeaderFooterView>
    public typealias SelectionProvider = ((ViewModel.CellIdentifier) -> Void)

    @Environment(\.layout) var customLayout

    @Binding var itemsPerSection: [ViewModel]
    let cellProvider: Diff.CellProvider
    var selectionProvider: SelectionProvider?
    
    private (set)var headerProvider: Diff.HeaderFooterProvider? = nil
    
    public init(_ items: Binding<[ViewModel]>,
                @ViewBuilder cellProvider: @escaping Diff.CellProvider) {
        self.cellProvider = cellProvider
        self._itemsPerSection = items
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, UICollectionViewDelegate {
    
        fileprivate let list: CompositionalList1
        @Binding fileprivate var itemsPerSection: [ViewModel]
        fileprivate let cellProvider: Diff.CellProvider
        
        fileprivate let layout: UICollectionViewLayout
        fileprivate let headerProvider: Diff.HeaderFooterProvider?
        fileprivate let selectionProvider: SelectionProvider?
        
        init(_ list: CompositionalList1) {

            self.list = list
            self.layout = list.customLayout
            self.cellProvider = list.cellProvider
            self.headerProvider = list.headerProvider
            self._itemsPerSection = list.$itemsPerSection
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
    
    public func selectedItem(_ selectionProvider: SelectionProvider?) -> Self {
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
    public convenience init(layout: UICollectionViewLayout,
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
