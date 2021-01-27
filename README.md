# CompositionalList 🧩
![gradienta-ix_kUDzCczo-unsplash (1)](https://user-images.githubusercontent.com/5378604/105889098-a7e48e80-5fc2-11eb-87a3-91a4d21a003b.jpg)
[![ForTheBadge built-with-love](http://ForTheBadge.com/images/badges/built-with-love.svg)](https://GitHub.com/Naereen/)
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)](https://github.com/Naereen/badges/)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![swift-version](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://github.com/apple/swift)
[![swiftui-version](https://img.shields.io/badge/swiftui-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![xcode-version](https://img.shields.io/badge/xcode-11%20-brightgreen)](https://developer.apple.com/xcode/)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)


CompositionalList is a SwiftUI UIViewControllerRepresentable wrapper powered by UIKit DiffableDataSource and Compositional Layout. 🥸  
It is customizable and flexible, supports multiple sections, cell selection. It allows to use any kind of SwiftUI view inside of cells, headers or footers.

# Requirements

* iOS 13.0 or later

# Features

- [X] Supports multiple sections.
- [X] Supports adapting UI to any kind of custom layout.
- [X] Supports cell selection.

CompositionalList adds `SwiftUI` views as children of `UICollectionViewCell's` and `UICollectionReusableView's` using `UIHostingController's`, it takes an array of data structures defined by a public protocol called `SectionIdentifierViewModel` that holds a section identifier and an array of cell identifiers.

```swift
public protocol SectionIdentifierViewModel {
    associatedtype SectionIdentifier: Hashable
    associatedtype CellIdentifier: Hashable
    var sectionIdentifier: SectionIdentifier { get }
    var cellIdentifiers: [CellIdentifier] { get }
}
```

`CompositionalList` basic structure looks like this...

```swift
struct CompositionalList<ViewModel, RowView, HeaderFooterView> where ViewModel : SectionIdentifierViewModel, RowView : View, HeaderFooterView : View
```

* `ViewModel` must conform to `SectionIdentifierViewModel`. To satisfy this protocol you must create a data structure that contains a section identifier, for example, an enum, and an array of objects that conform to `Hashable`.
* `RowView` the compiler will infer the return value in the `CellProvider` closure as long it conforms to `View`.
* `HeaderFooterView` must conform to `View`, which represents a header or a footer in a section. The developer must provide a view to satisfying the generic parameter. By now we need to return any kind of `View` to avoid the compiler force us to define the Types on initialization, if a header is not needed return a `Spacer` with a height of `0`.

# Getting Started

* Read this Readme doc
* Read the How to use section.
* Clone the [Example](https://github.com/jamesrochabrun/CompositionalList/tree/main/Example/CompositionalListExample) project as needed.

# How to use.

`CompositionalList` is initialized with an array of data structures that conforms to `SectionIdentifierViewModel` which represents a section, this means it can have one or X number of sections.

- **Step 1**, create a section identifier like this...

```swift
public enum SectionIdentifierExample: String, CaseIterable {
    case popular = "Popular"
    case new = "New"
    case top = "Top Items"
    case recent = "Recent"
    case comingSoon = "Coming Soon"
}
```

- **Step 2**, create a data structure that conforms to `SectionIdentifierViewModel`...

```swift
struct FeedSectionIdentifier: SectionIdentifierViewModel {
    let sectionIdentifier: SectionIdentifierExample // <- This is your identifier for each section.
    let cellIdentifiers: [FeedItemViewModel] // <- This is your model for each cell.
}
```

- **Step 3**, creating a section, this can be done inside a data provider view model that conforms to `ObservableObject`. 😉

 _For simplicity, here we are creating a single section, for the full code in how to create multiple sections check the [example source code](https://github.com/jamesrochabrun/CompositionalList/tree/main/Example/CompositionalListExample)._ 

```swift
struct Remote: ObservableObject {

@Published var sectionIdentifiers: [FeedSectionIdentifier]
  
  func fetch() {
/// your code for fetching some models...
    sectionIdentifiers = [FeedSectionIdentifier(sectionIdentifier: .popular, cellIdentifiers: models)]
  }
}
```

- **Step4** 🤖, initialize the `CompositionalList` with the array of section identifiers...


```swift
import CompositionalList

.....

    @ObservedObject private var remote = Remote()

    var body: some View {
       NavigationView {
    /// 5
          if items.isEmpty {
              ActivityIndicator()
          } else {
              CompositionalList(remote.sectionIdentifiers) { model, indexPath in
              /// 1
                  Group {
                     switch indexPath.section {
                     case 0, 2, 3:
                         TileInfo(artworkViewModel: model)
                     case 1:
                         ListItem(artworkViewModel: model)
                     default:
                         ArtWork(artworkViewModel: model)
                     }
                 }
             }.sectionHeader { sectionIdentifier, kind, indexPath in
             /// 2
                 TitleHeaderView(title: sectionIdentifier?.rawValue ?? "")
             }
             .selectedItem {
             /// 3
                 selectedItem = $0
             }
             /// 4
             .customLayout(.composed())
         }
      }.onAppear {
         remote.fetch()
      }
    }
```

1. `CellProvider` closure that provides a `model` and an `indexpath` and expects a `View` as the return value. Here you can return different `SwiftUI` views for each section, if you use a conditional statement like a `Switch` in this case, you must use a `Group` as the return value. For example in this case the compiler will infer this as the return value:

```swift
Group<_ConditionalContent<_ConditionalContent<TileInfo, ListItem>, ArtWork>>
```

2. `HeaderFooterProvider` closure that provides the section identifier, the `kind` which can be `UICollectionView.elementKindSectionHeader` or `UICollectionView.elementKindSectionFooter` this will be defined by your layout, and the indexPath for the corresponding section. It expects a `View` as a return value, you can customize your return value based on the section or if it's a header or a footer. Same as `CellProvider` if a conditional statement is used make sure to wrap it in a `Group`. This closure is required even If you don't define headers or footers in your layout you still need to return a `View`, in that case, you can return a `Spacer` with a height of 0. (looking for a more elegant solution by now 🤷🏽‍♂️).

3. `SelectionProvider` closure, internally uses `UICollectionViewDelegate` cell did select method to provide the selected item, this closure is optional.

4. `customLayout` environment object, here you can return any kind of layout as long is a `UICollectionViewLayout`.

5. For a reason that I still don't understand, we need to use a conditional statement verifying that the array is not empty, is handy for this case because we can return a spinner. 😬

# Installation

Installation with Swift Package Manager (Xcode 11+)
Swift Package Manager (SwiftPM) is a tool for managing the distribution of Swift code as well as C-family dependency. From Xcode 11, SwiftPM got natively integrated with Xcode.

CompositionalList support SwiftPM from version 5.1.0. To use SwiftPM, you should use Xcode 11 to open your project. `Click File` -> `Swift Packages` -> `Add Package Dependency,` enter CompositionalList repo's [URL](https://github.com/jamesrochabrun/CompositionalList). Or you can login Xcode with your GitHub account and just type CompositionalList to search.

After select the package, you can choose the dependency type (tagged version, branch or commit). Then Xcode will setup all the stuff for you.

### DEMO

![k1](https://user-images.githubusercontent.com/5378604/105805472-ecd2db80-5f56-11eb-9a11-787cc9f746bc.gif)

# **Important**:

Folow the [Example](https://github.com/jamesrochabrun/CompositionalList/tree/main/Example/CompositionalListExample) project 🤓
 
 CompositionalList is open source, feel free to collaborate!

TODO:

- [ ] Improve loading data, `UIVIewRepresentable` does not update its context, need to investigate why.
- [ ] Investigate why we need to make a conditional statement checking if the data is empty inside the view.
