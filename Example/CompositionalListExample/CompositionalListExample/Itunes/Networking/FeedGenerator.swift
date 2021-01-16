//
//  FeedGenerator.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/12/21.
//

import Foundation

enum MediaType {
    
    case appleMusic(feedType: AppleMusicFeedType, limit: Int)
    case itunesMusic(feedType: ItunesMusicFeedType, limit: Int)
    case apps(feedType: AppsFeedType, limit: Int)
    case audioBooks(feedType: AudioBooksFeedType, limit: Int)
    case books(feedType: BooksFeedType, limit: Int)
    case tvShows(feedType: TVShowFeedType, limit: Int)
    case movies(feedType: MovieFeedType, limit: Int)
    case podcast(feedType: PodcastFeedType, limit: Int)
    case musicVideos(feedType: MusicVideoFeedType, limit: Int)
    
    var path: String {
        switch self {
        case .appleMusic(let feedType, let limit): return "/apple-music/\(feedType.path)/\(limit)/explicit.json"
        case .itunesMusic(let feedType, let limit): return "/itunes-music/\(feedType.path)/\(limit)/explicit.json"
        case .apps(let feedType, let limit): return "/ios-apps/\(feedType.path)/\(limit)/explicit.json"
        case .audioBooks(let feedType, let limit): return "/audiobooks/\(feedType.path)/\(limit)/explicit.json"
        case .books(let feedType, let limit): return "/books/\(feedType.path)/\(limit)/explicit.json"
        case .tvShows(let feedType, let limit): return "/tv-shows/\(feedType.path)/\(limit)/explicit.json"
        case .movies(let feedType, let limit): return "/movies/\(feedType.path)/\(limit)/explicit.json"
        case .podcast(let feedType, let limit): return "/podcasts/\(feedType.path)/\(limit)/explicit.json"
        case .musicVideos(let feedType, let limit): return "/music-videos/\(feedType.path)/\(limit)/explicit.json"
        }
    }
}

/// Apple Music
enum AppleMusicFeedType {
    case comingSoon(genre: AppleMusicGenreType)
    case hotTracks(genre: AppleMusicGenreType)
    case newReleases(genre: AppleMusicGenreType)
    case topAlbums(genre: AppleMusicGenreType)
    case topSongs(genre: AppleMusicGenreType)
    
    var path: String {
        switch self {
        case .comingSoon(let genre): return "coming-soon/\(genre.rawValue)"
        case .hotTracks(let genre): return "hot-tracks/\(genre.rawValue)"
        case .newReleases(let genre): return "new-releases/\(genre.rawValue)"
        case .topAlbums(let genre): return "top-albums/\(genre.rawValue)"
        case .topSongs(let genre): return "top-songs/\(genre.rawValue)"
        }
    }
}

enum AppleMusicGenreType: String {
    case all
    case country
    case heavyMetal = "heavy-metal"
}

/// Itunes music
enum ItunesMusicFeedType {
    case hotTracks(genre: ItunesMusicGenreType)
    case newMusic(genre: ItunesMusicGenreType)
    case recentReleases(genre: ItunesMusicGenreType)
    case topAlbums(genre: ItunesMusicGenreType)
    case topSongs(genre: ItunesMusicGenreType)
    
    var path: String {
        switch self {
        case .hotTracks(let genre): return "hot-tracks/\(genre.rawValue)"
        case .newMusic(let genre): return "new-music/\(genre.rawValue)"
        case .recentReleases(let genre): return "recent-releases/\(genre.rawValue)"
        case .topAlbums(let genre): return "top-albums/\(genre.rawValue)"
        case .topSongs(let genre): return "top-songs/\(genre.rawValue)"
        }
    }
}

enum ItunesMusicGenreType: String {
    case all
    case country
    case heavyMetal = "heavy-metal"
}

/// Apps
enum AppsFeedType {
    
    case newAppsWeLove(genre: AppsGenreType)
    case newGamesWeLove(genre: AppsGenreType)
    case topFree(genre: AppsGenreType)
    case topFreeiPad(genre: AppsGenreType)
    case topGrossing(genre: AppsGenreType)
    case topGrossingiPad(genre: AppsGenreType)
    case topPaid(genre: AppsGenreType)
    
    var path: String {
        switch self {
        case .newAppsWeLove(let genre): return "new-apps-we-love/\(genre.rawValue)"
        case .newGamesWeLove(let genre): return "new-games-we-love/\(genre.rawValue)"
        case .topFree(let genre): return "top-free/\(genre.rawValue)"
        case .topFreeiPad(let genre): return "top-free-ipad/\(genre.rawValue)"
        case .topGrossing(let genre): return "top-grossing/\(genre.rawValue)"
        case .topGrossingiPad(let genre): return "top-grossing-ipad/\(genre.rawValue)"
        case .topPaid(let genre): return "top-paid/\(genre.rawValue)"
        }
    }
}

enum AppsGenreType: String {
    case all
    case games
}

/// AudioBooks
enum AudioBooksFeedType {
    case top(genre: AudioBooksGenreType)
    
    var path: String {
        switch self {
        case .top(let genre): return "top-audiobooks/\(genre.rawValue)"
        }
    }
}

enum AudioBooksGenreType: String {
    case all
}

/// Books
enum BooksFeedType {
    case topFree(genre: BooksGenreType)
    case topPaid(genre: BooksGenreType)
    
    var path: String {
        switch self {
        case .topFree(let genre): return "top-free/\(genre.rawValue)"
        case .topPaid(let genre): return "top-paid/\(genre.rawValue)"
        }
    }
}

enum BooksGenreType: String {
    case all
}

/// TV
enum TVShowFeedType {
    case topTVEpisodes(genre: TVShowGenreType)
    case topTVSeasons(genre: TVShowGenreType)
    
    var path: String {
        switch self {
        case .topTVEpisodes(let genre): return "top-tv-episodes/\(genre.rawValue)"
        case .topTVSeasons(let genre): return "top-tv-seasons/\(genre.rawValue)"
        }
    }
}

enum TVShowGenreType: String {
    case all
}


/// Movies
enum MovieFeedType {
    case top(genre: MovieGenreType)
    
    var path: String {
        switch self {
        case .top(let genre): return "top-movies/\(genre.rawValue)"
        }
    }
}

enum MovieGenreType: String {
    case all
}

/// Itunes U
enum ItunesUFeedType {
    case top(genre: ItunesUGenreType)
    
    var path: String {
        switch self {
        case .top(let genre): return "top-itunes-u-courses/\(genre.rawValue)"
        }
    }
}

enum ItunesUGenreType: String {
    case all
}

/// Podcasts
enum PodcastFeedType {
    case top(genre: PodcastGenreType)
    
    var path: String {
        switch self {
        case .top(let genre): return "top-podcasts/\(genre.rawValue)"
        }
    }
}

enum PodcastGenreType: String {
    case all
}


/// Music Videos
enum MusicVideoFeedType {
    case top(genre: MusicVideGenreType)
    
    var path: String {
        switch self {
        case .top(let genre): return "top-music-videos/\(genre.rawValue)"
        }
    }
}

enum MusicVideGenreType: String {
    case all
}


struct Itunes {
    
    private var base: String {
        "https://rss.itunes.apple.com"
    }
    
    var mediaTypePath: MediaType
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)! //forceunwrapped becuase we know it exists
        components.path = "/api/v1/us" + mediaTypePath.path
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url! //want to crash if no information is complete
        return URLRequest(url: url)
    }
}
