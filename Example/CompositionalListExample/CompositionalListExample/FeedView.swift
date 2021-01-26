//
//  FeedView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/22/21.
//

import SwiftUI
import CompositionalList

struct FeedView: View {
    
    @Binding var items: [GenericSectionIdentifierViewModel<SectionIdentifierExample, FeedItemViewModel>]
    @State var selectedItem: FeedItemViewModel?
    
    var body: some View {
        if items.isEmpty {
            ActivityIndicator()
        } else {
            CompositionalList(items) { model, indexPath in
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
                TitleHeaderView(title: sectionIdentifier?.rawValue ?? "")
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

struct TitleHeaderView: View {
    
    let title: String
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .bold()
                    .font(.title)
                Spacer()
            }
            Divider()
        }
        .padding()
    }
}


//
//struct FeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedView(items: [])
//    }
//}
