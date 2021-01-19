//
//  ItunesRemote.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Foundation
import Combine
import CompositionalList

struct GenericSectionIdentifierViewModel<SectionIdentifier: Hashable, CellIdentifier: Hashable>: SectionIdentifierViewModel {
    var sectionIdentifier: SectionIdentifier? = nil
    var cellIdentifiers: [CellIdentifier]
}

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
            let chunkCount = feed.feed.results.count / SectionIdentifierExample.allCases.count
            let chunks = feed.feed.results.map { FeedItemViewModel(model: $0) }.chunked(into: chunkCount)
            var sectionIdentifiers: [GenericSectionIdentifierViewModel<SectionIdentifierExample, FeedItemViewModel>] = []
            for i in 0..<SectionIdentifierExample.allCases.count {
                sectionIdentifiers.append(GenericSectionIdentifierViewModel(sectionIdentifier: SectionIdentifierExample.allCases[i], cellIdentifiers: chunks[i]))
            }
           self.feedItems = sectionIdentifiers
        })
    }
}

// Helper, currenlt Itunes RSS feed does not return sectioned data, in order to
// show how compositional list works with sections we chunked the available data from the Itunes API.
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
