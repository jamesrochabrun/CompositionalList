//
//  FeedGenerator.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Foundation

enum Format: String {
    case json = ".json"
    case xml = ".xml"
    case atom = ".atom"
}

enum MediaType {

    case apps(contentType: AppsContentType, chart: AppsChart, limit: Int, format: Format)
    case audioBooks(contentType: AudioBooksContentType, chart: AudiobooksChart, limit: Int, format: Format)
    case music(contentType: MusicContentType, chart: MusicChart, limit: Int, format: Format)
    case books(contentType: BooksContentType, chart: BooksChart, limit: Int, format: Format)
    case podcasts(contentType: PodcastsContentType, chart: PodcastsChart, limit: Int, format: Format)
    
    var path: String {
        switch self {
        case .apps(let contentType, let chart, let limit, let format): return "/\(Itunes.ItunesMediaType.apps)/\(chart.rawValue)/\(limit)/\(contentType.rawValue)\(format.rawValue)"
        case .audioBooks(let contentType, let chart, let limit, let format): return "/\(Itunes.ItunesMediaType.audioBooks.rawValue)/\(chart.rawValue)/\(limit)/\(contentType.rawValue)\(format.rawValue)"
        case .music(let contentType, let chart, let limit, let format): return "/\(Itunes.ItunesMediaType.music.rawValue)/\(chart.rawValue)/\(limit)/\(contentType.rawValue)\(format.rawValue)"
        case .books(let contentType, let chart, let limit, let format): return "/\(Itunes.ItunesMediaType.books.rawValue)/\(chart.rawValue)/\(limit)/\(contentType.rawValue)\(format.rawValue)"
        case .podcasts(let contentType, let chart, let limit, let format): return "/\(Itunes.ItunesMediaType.podcasts.rawValue)/\(chart.rawValue)/\(limit)/\(contentType.rawValue)\(format.rawValue)"
            
        }
    }
}

/// Apps
enum AppsContentType: String {
    case apps
}

enum AppsChart: String {
    case topPaid = "top-paid"
    case topFree = "top-free"
}

/// AudioBooks
enum AudioBooksContentType: String {
    case audiobooks = "audio-books"
}

enum AudiobooksChart: String {
    case top
}

// Music
enum MusicContentType: String {
    case albums
    case musicVideos = "music-videos"
    case playlists
    case songs
}

enum MusicChart: String {
    case mostPlayed = "most-played"
}

// Books
enum BooksContentType: String {
    case books
}

enum BooksChart: String {
    case topPaid = "top-paid"
    case topFree = "top-free"
}

// Podcats
enum PodcastsContentType: String {
    case episodes = "podcast-episodes"
    case podcasts
}

enum PodcastsChart: String {
    case top
}

struct Itunes {
    
    private var base: String {
        "https://rss.applemarketingtools.com"
    }
    
    var mediaTypePath: MediaType
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)! //forceunwrapped becuase we know it exists
        components.path = "/api/v2/us" + mediaTypePath.path
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url! //want to crash if no information is complete
        return URLRequest(url: url)
    }
    
    enum ItunesMediaType: String, CaseIterable {
        
        case apps
        case music
        case podcasts
        case books
        case audioBooks = "audio-books"
        
        var title: String {
            switch self {
            case .audioBooks: return "Audio Books"
            default: return rawValue.capitalized
            }
        }
        
        var imageSystemName: String {
            switch self {
            case .music: return "music.note.list"
            case .apps: return "apps.iphone"
            case .books: return "book"
            case .podcasts: return "dot.radiowaves.left.and.right"
            case .audioBooks: return "tv.music.note.fill"
            }
        }
    }
}
