//
//  MarvelProvider.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import Combine
import MarvelClient

final class MarvelProvider: ObservableObject {

    private let service = MarvelService(privateKey: "6905a8e2fb2033fdb10eea66645116669f1c4f04", publicKey: "27d25dbafd3ff80a9d448a19c11ace4d")

    @Published var series: [SerieViewModel] = []
    @Published var characters: [CharacterViewModel] = []
    @Published var comics: [ComicViewModel] = []
        
    func fetchSeries() {
        service.fetch(MarvelData<Resources<Serie>>.self) { resource in
            switch resource {
            case .success(let results):
                self.series = results.map { SerieViewModel(model: $0) }
            case .failure: break
            }
        }
    }

    func fetchCharacters() {
        service.fetch(MarvelData<Resources<Character>>.self) { resource in
            switch resource {
            case .success(let results):
                self.characters = results.map { CharacterViewModel(model: $0) }
            case .failure: break
            }
        }
    }

    func fetchComics() {
        service.fetch(MarvelData<Resources<Comic>>.self) { resource in
            switch resource {
            case .success(let results):
                self.comics = results.map { ComicViewModel(model: $0) }
            case .failure: break
            }
        }
    }
}
