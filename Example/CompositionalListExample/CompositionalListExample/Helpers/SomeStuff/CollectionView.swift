//
//  CollectionView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/19/21.
//

import SwiftUI
import CompositionalList

struct CollectionView<Section: Hashable & CaseIterable, Item: Hashable>: UIViewControllerRepresentable {

    // MARK: - Properties
    let layout: UICollectionViewLayout
    let sections: [Section]
    let items: [Section: [Item]]

    // MARK: - Actions
    let snapshot: (() -> NSDiffableDataSourceSnapshot<Section, Item>)?
    let content: (_ indexPath: IndexPath, _ item: Item) -> AnyView

    // MARK: - Init
    init(layout: UICollectionViewLayout,
         sections: [Section],
         items: [Section: [Item]],
         snapshot: (() -> NSDiffableDataSourceSnapshot<Section, Item>)? = nil,
         @ViewBuilder content: @escaping (_ indexPath: IndexPath, _ item: Item) -> AnyView) {
        self.layout = layout

        self.sections = sections
        self.items = items

        self.snapshot = snapshot
        self.content = content
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CollectionViewController<Section, Item> {

        let controller = CollectionViewController<Section, Item>()

        controller.layout = self.layout

        controller.snapshotForCurrentState = {

            if let snapshot = self.snapshot {
                return snapshot()
            }

            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

            snapshot.appendSections(self.sections)

            self.sections.forEach { section in
                snapshot.appendItems(self.items[section]!, toSection: section)
            }

            return snapshot
        }

        controller.content = content

        controller.collectionView.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: CollectionViewController<Section, Item>, context: Context) {

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

struct CollectionView_Previews: PreviewProvider {

    enum Section: CaseIterable {
        case features
        case categories
    }

    enum Item: Hashable {
        case feature(feature: Feature)
        case category(category: Category)
    }

    class Feature: Hashable{
        let id: String
        let title: String

        init(id: String, title: String) {
            self.id = id
            self.title = title
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }

        static func ==(lhs: Feature, rhs: Feature) -> Bool {
            lhs.id == rhs.id
        }
    }

    class Category: Hashable {
        let id: String
        let title: String

        init(id: String, title: String) {
            self.id = id
            self.title = title
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }

        static func ==(lhs: Category, rhs: Category) -> Bool {
            lhs.id == rhs.id
        }
    }

    static let items: [Section: [Item]] = {
        return [
            .features : [
                .feature(feature: Feature(id: "1", title: "Feature 1")),
                .feature(feature: Feature(id: "2", title: "Feature 2")),
                .feature(feature: Feature(id: "3", title: "Feature 3"))
            ],
            .categories : [
                .category(category: Category(id: "1", title: "Category 1")),
                .category(category: Category(id: "2", title: "Category 2")),
                .category(category: Category(id: "3", title: "Category 3"))
            ]
        ]
    }()

    static var previews: some View {

        func generateLayout() -> UICollectionViewLayout {

            let itemHeightDimension = NSCollectionLayoutDimension.absolute(44)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: itemHeightDimension)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: itemHeightDimension)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }

        return CollectionView(layout: generateLayout(), sections: [.features], items: items, snapshot: {

            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections(Section.allCases)

            items.forEach { (section, items) in
                snapshot.appendItems(items, toSection: section)
            }

            return snapshot

        }) { (indexPath, item) -> AnyView in

            switch item {
            case .feature(let item):
                return AnyView(Text("Feature \(item.title)"))
            case .category(let item):
                return AnyView(Text("Category \(item.title)"))
            }
        }

    }
}

class CollectionViewController<Section, Item>: UIViewController
    where Section : Hashable & CaseIterable, Item : Hashable {

    var layout: UICollectionViewLayout! = nil
    var snapshotForCurrentState: (() -> NSDiffableDataSourceSnapshot<Section, Item>)! = nil
    var content: ((_ indexPath: IndexPath, _ item: Item) -> AnyView)! = nil

    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: cellProvider)
        return dataSource
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
    }
}

extension CollectionViewController {

    private func configureCollectionView() {
        view.addSubview(collectionView)

      //  collectionView.register(WrapperViewCell<RowView>.self)
    }


    private func configureDataSource() {

        // load initial data
        let snapshot : NSDiffableDataSourceSnapshot<Section, Item> = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? {

        print("Providing cell for \(indexPath)")
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HostingControllerCollectionViewCell<AnyView>.reuseIdentifier, for: indexPath) as? HostingControllerCollectionViewCell<AnyView> else {
//            fatalError("Coult not load cell!")
//        }

       // cell.host(content(indexPath, item))

        return nil
    }
}

extension CollectionViewController {

    func updateUI() {
        let snapshot : NSDiffableDataSourceSnapshot<Section, Item> = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
