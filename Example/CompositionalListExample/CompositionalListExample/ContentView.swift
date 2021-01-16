//
//  ContentView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

struct ContentView: Parent {
    
    @ObservedObject private var remote = ItunesRemote()
    
    let parent: UIViewController
    
    var body: some View {

        Group {
            if remote.feedItems.isEmpty {
                ActivityIndicator()
            } else {
                CompositionalList(remote.feedItems, parent: parent) { model, indexPath in
                    Group {
                        switch indexPath.section {
                        case 0:
                            TileInfo(artworkViewModel: model)
                                .border(Color.blue)
                        case 1:
                            ListItem(artworkViewModel: model)
                                .border(Color.blue)
                        default:
                            ArtWork(artworkViewModel: model)
                                .border(Color.blue)
                        }
                    }
                    // step 3: provide a `sectionHeader` can be a Spacer with height 0
                }.sectionHeader { sectionIdentifier, kind, indexPath in
                    HStack {
                        Text(sectionIdentifier!.rawValue)
                            .bold()
                            .font(.title)
                        Spacer()
                    }
                    .padding()
                  //  .padding(.vertical, 5)
                    .border(Color.blue)
                }
                // step 4: provide a `UICollectionViewLayout`
                .customLayout(.composed())
                .navigationBarTitle(Text("Home Feed"))
            }
        }
        .onAppear {
            
           // remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 100))
            //remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
            remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
           // remote.fetchItems(.itunesMusic(feedType: .topSongs(genre: .all), limit: 200))
        }
    }
}



//struct SomeHeader: View {
//
//    var sectionIdentifier: SectionIdentifier
//    var newAppsWeLove: [FeedItemViewModel]
//
//    var body: some View {
//        VStack {
//            Text(sectionIdentifier.rawValue)
//            ScrollView (.horizontal, showsIndicators: false) {
//                 HStack {
//                     //contents
//                    ForEach(newAppsWeLove, id: \.id) { app in
////                                    CarachterArtworkView(artworkViewModel: comic.artwork!, variant: .squareStandardSmall)
//                        Text(app.name)
//                       Divider()
//                     }
//                 }
//            }.frame(height: 100)
//        }
//    }
//}

struct GenericSectionIdentifierViewModel<SectionIdentifier: Hashable, CellIdentifier: Hashable>: SectionIdentifierViewModel {
    var sectionIdentifier: SectionIdentifier? = nil
    var cellIdentifiers: [CellIdentifier]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(parent: UIViewController())
    }
}

public extension UICollectionViewLayout {
    
    // Composed layout example.
    static func composed() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section: NSCollectionLayoutSection
            switch sectionIndex {
            case 0:
                section = NSCollectionLayoutSection.horizontalTiles(scrollingBehavior: .continuousGroupLeadingBoundary, header: true)
            case 1:
                section = NSCollectionLayoutSection.listLOL(scrollingBehavior: .continuousGroupLeadingBoundary, header: true)
            default:
                section = NSCollectionLayoutSection.tilesSection(header: true, footer: false)
            }
            return layoutEnvironment.isPortraitEnvironment ? section : NSCollectionLayoutSection.grid(3)
        }
    }
}

extension NSCollectionLayoutSection {
    
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
    
    // section 0
    static func horizontalTiles(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
                         header: Bool = false,
                         footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])
        let layoutSection: NSCollectionLayoutSection = .init(group: group)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)
        return layoutSection
    }
    
    // section 1
    static func listLOL(rows: CGFloat = 4,
                        itemHeight: CGFloat = 50,
        scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
                         header: Bool = false,
                         footer: Bool = false) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(itemHeight))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 0, bottom: 5, trailing: 0)
        
        let layoutGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(0.92),
                              heightDimension: .absolute(itemHeight * rows)),
            subitem: layoutItem, count: Int(rows))
            
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.boundarySupplementaryItems = supplementaryItems(header: header, footer: footer)

        return layoutSection
    }
}
