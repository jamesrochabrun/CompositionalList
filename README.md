# CompositionalList 🧩

CompositionalList is a `SwiftUI` `UIViewControllerRepresentable` wrapper powered by `UIKit` `DiffableDataSource` and `Compositional Layout`. 🥸

It adds `SwiftUI` views as children of `UICollectionViewCell's` and `UICollectionReusableView's` using `UIHostingController's`, it takes an array of data structures defined by a public protocol called `SectionIdentifierViewModel` that holds a section identifier and an array of cell identifiers.

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

* `ViewModel` must conform to `SectionIdentifierViewModel`. To satisfy this protocol you must create a data structure that contains a section identifier, for example an enum, and an array of objects that conform to `Hashable`.

*  `RowView` the compiler will infer the return value in the `CellProvider` closure as long it conforms to `View`.
*  `HeaderFooterView` must conform to `View`, represents a header or a footer in a section. Dev must provide a view to satisfy the generic parameter. By now we need to return something so compiler does not force us to define the Types on initialization, if a header is not needed return a `Spacer` with height of  `0`.

# Usage

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

- **Step 2**, create a data structure that conforms to `SectionIdentifierViewModel`, it can be a generic one like this...

```swift
public struct GenericSectionIdentifierViewModel<SectionIdentifier: Hashable, CellIdentifier: Hashable>: SectionIdentifierViewModel {
    public var sectionIdentifier: SectionIdentifier? = nil
    public var cellIdentifiers: [CellIdentifier]
}
```

- **Step 3**, creating a section, this can be done inside a data provider view model that conforms to `ObservableObject`. 😉

```swift
/// Here we create a single section, this needs to be adapted on the structure of your payload.
struct Remote: ObservableObject {

@Published var sectionIdentifiers: [GenericSectionIdentifierViewModel]
  
  func fetch() {
/// your code for fetching some models...
/// This is just one example of one section, this will vary on the structure of your payload, customize based on your needs.
    sectionIdentifiers = [GenericSectionIdentifierViewModel(sectionIdentifier: .popular, cellIdentifiers: models)]
  }
}
```

- **Step4** 🤖


```swift
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

1. `CellProvider` closure that provides a `model` and an `indexpath` and expects a `View` as return value. Here you can return different `SwiftUI` views for each section, if you use a conditional statement like a `Switch` in this case, you must use a `Group` as the return value, for example in this case the compiler will infer this as the return value:

```swift
Group<_ConditionalContent<_ConditionalContent<TileInfo, ListItem>, ArtWork>>
```

2. `HeaderFooterProvider` closure that provides the section identifier, the `kind` which can be `UICollectionView.elementKindSectionHeader` or `UICollectionView.elementKindSectionFooter` this will be defined by your layout. An indexPath for the corresponding section. It expects a `View` as a return value, you can customize your return value based on the section or if it's a header or a footer. Same as `CellProvider` if a conditional statement is used make sure to wrap it in a `Group`. This closure is required even If you don't define headers or footers in your layout you still need to return a `View`, in that case you can return a `Spacer` with height of 0. (looking for a more elegant solution by now 🤷🏽‍♂️).

3. `SelectionProvider` closure, internally uses `UICollectionViewDelegate` cell did select method to provide the selected item, this closure is optional.

4. `customLayout` environment object, here you can return any kind of layout as long is a `UICollectionViewLayout`.

5. For a reason that I still don't understand, we need to use a conditional statement verifying that the array is not empty, is handy for this case because we can return a spinner. 😬


![k1](https://user-images.githubusercontent.com/5378604/105805472-ecd2db80-5f56-11eb-9a11-787cc9f746bc.gif)

### **Important**:

Folow the Example project 🤓

 https://github.com/jamesrochabrun/CompositionalList/tree/main/Example/CompositionalListExample 
 
 CompositionalList is open source, feel free to collaborate!

TODO:

- [ ] Improve loading data, `UIVIewRepresentable` does not update its context, need to investigate why.
- [ ] Investigate why we need to make a check 
