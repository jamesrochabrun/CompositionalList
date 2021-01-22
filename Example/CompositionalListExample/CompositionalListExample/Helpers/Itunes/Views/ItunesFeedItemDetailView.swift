//
//  ItunesFeedItemDetailView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/20/21.
//

import SwiftUI

struct ItunesFeedItemDetailView: View {
    
    @ObservedObject var viewModel: FeedItemViewModel
    
    var body: some View {
        ArtWork(artworkViewModel: viewModel)
    }
}

struct ItunesFeedItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItunesFeedItemDetailView(viewModel: FeedItemViewModel(model: FeedItem(artistName: nil, id: "", releaseDate: nil, name: "", kind: "", copyright: "", artistId: "", artistUrl: "", artworkUrl100: "", genres: [], url: "")))
    }
}
