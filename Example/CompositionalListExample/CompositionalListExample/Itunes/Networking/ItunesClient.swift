//
//  ItunesClient.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Combine
import Foundation
import MarvelClient

final class ItunesClient: CombineAPI {
    
    // 1
    let session: URLSession
    
    // 2
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    // 3
    public func fetch<Feed: FeedProtocol>(_ feed: Feed.Type,
                                          mediaType: MediaType) -> AnyPublisher<Feed, Error> {
        
        let itunes = Itunes(mediaTypePath: mediaType)
        print("PATH: \(String(describing: itunes.request.url?.absoluteString))")

        return execute(itunes.request, decodingType: feed)
    }
}

