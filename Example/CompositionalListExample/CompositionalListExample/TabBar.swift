//
//  TabBar.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList


struct TabBar: View {
    
    var body: some View {
        TabView {
            ForEach(0..<Itunes.ItunesFeedKind.allCases.count, id: \.self) { index in
                let kind = Itunes.ItunesFeedKind.allCases[index]
                FeedContainerView(feedKind: kind)
                    .tabItem {
                        Image(systemName: kind.imageSystemName)
                        Text(kind.title)
                    }
            }
        }
    }
}
