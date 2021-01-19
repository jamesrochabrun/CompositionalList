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
                }
                // step 4: provide a `UICollectionViewLayout`
                .customLayout(.composed())
            }
        }
        .onAppear {
            // remote.fetchItems(.appleMusic(feedType: .topSongs(genre: .all), limit: 200))
            //  remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
            //  remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 100))
            //  remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 100))
            //   remote.fetchItems(.podcast(feedType: .top(genre: .all), limit: 200))
            remote.fetchItems(.itunesMusic(feedType: .topSongs(genre: .all), limit: 200))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(parent: UIViewController())
    }
}
