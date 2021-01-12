//
//  ContentView.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

// Step 1: create a section identifier
enum CharacterSectionIdentifier: String {
    case mainSection
    case secondarySection
}

struct ContentView: View {
    
    @ObservedObject private var provider = MarvelProvider()
    
    var body: some View {
        
        Group {
            if provider.characters.isEmpty {
                ActivityIndicator()
            } else {
                
                // Step 2: create objects that conform to `SectionIdentifierViewModel`
                let newCharactersSection = GenericSectionIdentifierViewModel(sectionIdentifier: CharacterSectionIdentifier.mainSection, cellIdentifiers: provider.characters)
                
                CompositionalList([newCharactersSection]) { model, indexPath in
                    Group {
                        switch indexPath.section {
                        case 0:
                            CarachterArtworkView(artworkViewModel: model.artwork!, variant: .landscapeAmazing)
                                .border(Color.blue)
                        default:
                            CarachterArtworkView(artworkViewModel: model.artwork!, variant: .portraitUncanny)
                                // .aspectRatio(1, contentMode: .fit)
                                //   .scaledToFit()
                                .border(Color.blue)
                        }
                    }
                    // step 3: provide a `sectionHeader` can be a Spacer with height 0
                }.sectionHeader { sectionIdentifier, kind, indexPath in
                    Text(sectionIdentifier!.rawValue)
                }
                // step 4: provide a `UICollectionViewLayout`
                .customLayout(.composedLayout())
            }
        }
        .onAppear {
            provider.fetchCharacters()
        }
    }
}

struct GenericSectionIdentifierViewModel<SectionIdentifier: Hashable, CellIdentifier: Hashable>: SectionIdentifierViewModel {
    var sectionIdentifier: SectionIdentifier? = nil
    var cellIdentifiers: [CellIdentifier]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
