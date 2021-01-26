//
//  ArtWork.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ArtWork: View {
    
        @ObservedObject var artworkViewModel: FeedItemViewModel

        var body: some View {
            WebImage(url: artworkViewModel.artworkURL)
                // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                .onSuccess { image, data, cacheType in
                    // Success
                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                }
                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                .placeholder(Image(systemName: "photo")) // Placeholder Image
                // Supports ViewBuilder as well
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5)) // Fade Transition with duration
               .frame(maxWidth: .infinity, maxHeight: .infinity)
               // .frame(idealWidth: 100, idealHeight: 100)
             //   .scaledToFill()
        }
}

struct TileInfo: View {
    
    @ObservedObject var artworkViewModel: FeedItemViewModel

    var body: some View {
 
        VStack(alignment: .leading) {
             ArtWork(artworkViewModel: artworkViewModel)
              //  .scaledToFill()
            //Rectangle()
              //  .aspectRatio(1, contentMode: .fill)
                // .aspectRatio(CGSize(width: 100, height: 100), contentMode: .fill)
                .cornerRadius(5.0)
            VStack(alignment: .leading, spacing: 3) {
                Text(artworkViewModel.artistName ?? artworkViewModel.name)
                    .modifier(PrimaryFootNote())
                Text(artworkViewModel.genres.first?.name ?? "blob")
                    .modifier(SecondaryFootNote())
            }
        }
    }
}

struct ListItem: View {
    
    @ObservedObject var artworkViewModel: FeedItemViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            ArtWork(artworkViewModel: artworkViewModel)
                .frame(width: 50, height: 50)
                .clipped()
               .cornerRadius(3.0)
            VStack(alignment: .leading, spacing: 3) {
                Text(artworkViewModel.artistName ?? artworkViewModel.name)
                    .modifier(PrimaryFootNote())
                Text(artworkViewModel.genres.first?.name ?? "")
                    .modifier(SecondaryFootNote())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PrimaryTitle: ViewModifier {
        
    func body(content: Content) -> some View {
        content
            .foregroundColor(.primary)
            .font(.title)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

struct PrimaryFootNote: ViewModifier {
        
    func body(content: Content) -> some View {
        content
            .foregroundColor(.primary)
            .font(.callout)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

struct SecondaryFootNote: ViewModifier {
        
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

