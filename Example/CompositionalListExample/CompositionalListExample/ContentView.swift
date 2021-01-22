//
//  ContentView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

struct ContentView: View {

    @ObservedObject private var remote = ItunesRemote()
    @State var selectedItem: FeedItemViewModel?
    var navigationBarTitle: Text {
        Text(Itunes.ItunesFeedKind(kind: remote.feedItems.first?.cellIdentifiers.first?.kind ?? "")?.title ?? "Home")
    }
    
    var body: some View {
        NavigationView {
            if remote.feedItems.isEmpty {
                ActivityIndicator()
            } else {
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
                .navigationBarTitle(navigationBarTitle)
                .sheet(item: $selectedItem) { item in
                    ItunesFeedItemDetailView(viewModel: item)
                }
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
