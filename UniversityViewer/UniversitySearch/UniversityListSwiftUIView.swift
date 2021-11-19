//
//  UniversityListSwiftUIView.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import SwiftUI
import Combine
import UniversitySearch

struct UniversitySwiftUIView: View {
#warning("I don't like that I have to pass in the entire UniversityViewModel here, but if I wanted to just pass in the University model, I would have to make the University model conform to ObservableObject.")
    @ObservedObject var uniModel: UniversityViewModel
    
    #warning("What other potential approach could be taken instead of passing in completion blocks to handle button taps and communicate back to the parent UIKit view controller? Something more oriented around combine and binding?")
    var onUniversityTap: ((University) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            List(uniModel.universities, id: \.id) { university in
                HStack() {
                    UniListViewItem(uni: university)
                    Spacer()
                }.frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                    .onTapGesture {
                    onUniversityTap?(university)
                }
            }.listStyle(.plain)
        }
    }
}

struct UniListViewItem: View {
    var uni: University

    var body: some View {
        VStack(alignment: .leading) {
            Text(uni.name)
                .padding(EdgeInsets(top: 0,
                                    leading: 0,
                                    bottom: 8,
                                    trailing: 0))
                .foregroundColor(.orange)
            Text(uni.country)
                .padding(EdgeInsets(top: 0,
                                    leading: 0,
                                    bottom: 4,
                                    trailing: 0))
        }.alignmentGuide(.leading) { dim in
            return 0
        }
    }
}

#warning("What would be an easy way to be able to preview this SwiftUI view? I would have to create a UniversityViewModel which would require making a UniversityLoader, which requires a HTTPClient... Would a mock version only used for previewing be alright")
//struct UniversityHostingController_Previews: PreviewProvider {
//    static var previews: some View {
//        UniversitySwiftUIView(uniModel: )
//    }
//}
