//
//  Feed.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Foundation

public struct Author: Decodable {
    let name: String
    let uri: String
}

public protocol ItunesResource: Decodable {
    associatedtype Model
    var title: String { get }
    var id: String { get }
    var author: Author { get }
    var copyright: String { get }
    var country: String { get }
    var icon: String { get }
    var updated: String { get }
    var results: [Model] { get }
}

public struct ItunesResources<Model: Decodable>: ItunesResource {
    
    public let title: String
    public let id: String
    public let author: Author
    public let copyright: String
    public let country: String
    public let icon: String
    public let updated: String
    public let results: [Model]
}

public protocol FeedProtocol: Decodable {
    associatedtype FeedResource: ItunesResource
    var feed: FeedResource { get }
}

public struct Feed<FeedResource: ItunesResource>: FeedProtocol {
    public let feed: FeedResource
}
