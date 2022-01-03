//
//  FeedContainerView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/22/21.
//

import SwiftUI

struct FeedContainerView: View {
    
    @StateObject private var remote = ItunesRemote()
    
    var navigationBarTitle: Text {
        Text(remote.feedItems.first?.cellIdentifiers.first?.kind.capitalized ?? "Loading...")
    }
    
    var feedKind: Itunes.ItunesMediaType
    
    var body: some View {
        NavigationView {
            FeedView(items: $remote.feedItems, selectedItem: nil)
                .ignoresSafeArea()
                .navigationBarTitle(navigationBarTitle)
        }
        .onAppear {
            switch feedKind {
            case .apps:
                remote.fetchItems(.apps(contentType: .apps, chart: .topFree, limit: 100, format: .json))
            case .books:
                remote.fetchItems(.books(contentType: .books, chart: .topFree, limit: 100, format: .json))
            case .podcasts:
                remote.fetchItems(.podcasts(contentType: .podcasts, chart: .top, limit: 100, format: .json))
            case .audioBooks:
                remote.fetchItems(.audioBooks(contentType: .audiobooks, chart: .top, limit: 100, format: .json))
            case .music:
                remote.fetchItems(.music(contentType: .albums, chart: .mostPlayed, limit: 100, format: .json))
            }
        }
    }
}

struct FeedContainerView_Previews: PreviewProvider {
    static var previews: some View {
        FeedContainerView(feedKind: .apps)
    }
}
