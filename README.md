### Welcome to my test app for trying out combine, SwiftUI (hosted within HostingControllers in UIKit), and the new async concurrency APIs.

The app is simple. It consists of a search bar, a list view to display search results and the ability to tap on a search result and navigate to a view that displays further content from the search result.

The content of the list is made up of information on Universities that comes from a public API. Information about the API can be found [here](https://github.com/Hipo/university-domains-list).

The user can search the API by typing in the search bar and the results for the search will be displayed within the list. There is a default search of `san` just for the sake of not showing an empty list.

There is one dependency imported through the Swift Package Manager. It is SnapKit and is used for simplifying the process of adding code-based constraints. Info about it can be found [here](https://github.com/SnapKit/SnapKit).


### Warnings
I have created warnings throughout the app to highlight areas that I have questions about and would like to explore other options for implementation.