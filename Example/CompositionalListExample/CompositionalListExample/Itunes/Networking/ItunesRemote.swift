//
//  ItunesRemote.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Foundation
import Combine

// Step 1: create a section identifier
enum SectionIdentifierExample: String, CaseIterable {
    case popular = "Popular"
    case new = "New"
    case top = "Top Items"
    case recent = "Recent"
    case comingSoon = "Coming Soon"
}


final class ItunesRemote: ObservableObject {

    private let service = ItunesClient()
    private var cancellable: AnyCancellable?

    @Published var feedItems: [GenericSectionIdentifierViewModel<SectionIdentifierExample, FeedItemViewModel>] = []

    func fetchItems(_ mediaType: MediaType) {
        cancellable = service.fetch(Feed<ItunesResources<FeedItem>>.self, mediaType: mediaType).sink(receiveCompletion: {
            dump($0)
        }, receiveValue: { feed in
            
            let chunks = feed.feed.results.map { FeedItemViewModel(model: $0) }.chunked(into: SectionIdentifierExample.allCases.count)
            var sectionIdentifiers: [GenericSectionIdentifierViewModel<SectionIdentifierExample, FeedItemViewModel>] = []
            for i in 0..<SectionIdentifierExample.allCases.count {
                sectionIdentifiers.append(GenericSectionIdentifierViewModel(sectionIdentifier: SectionIdentifierExample.allCases[i], cellIdentifiers: chunks[i]))
            }
           self.feedItems = sectionIdentifiers
        })
    }
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
