//
//  FeedContainerView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/22/21.
//

import SwiftUI

struct FeedContainerView: View {
    
    @ObservedObject private var remote = ItunesRemote()
    var navigationBarTitle: Text {
        Text(Itunes.ItunesFeedKind(kind: remote.feedItems.first?.cellIdentifiers.first?.kind ?? "")?.title ?? "Loading...")
    }
    var feedKind: Itunes.ItunesFeedKind
    
    var body: some View {
        NavigationView {
            FeedView(items: $remote.feedItems, selectedItem: nil)
            .navigationBarTitle(navigationBarTitle)
        }
        .onAppear {
            switch feedKind {
            case .music:
                remote.fetchItems(.appleMusic(feedType: .topSongs(genre: .all), limit: 200))
            case .apps:
                remote.fetchItems(.apps(feedType: .topFree(genre: .all), limit: 200))
            case .books:
                remote.fetchItems(.books(feedType: .topFree(genre: .all), limit: 200))
            case .tvShows:
                remote.fetchItems(.tvShows(feedType: .topTVSeasons(genre: .all), limit: 200))
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
struct FeedContainerView_Previews: PreviewProvider {
    static var previews: some View {
        FeedContainerView(feedKind: .apps)
    }
}
