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
    @ObservedObject var uniModel: UniversityViewModel
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

//struct UniversityHostingController_Previews: PreviewProvider {
//    static var previews: some View {
//        UniversitySwiftUIView(uniModel: getUniVM())
//    }
//}

//func getUniVM() -> UniversityViewModel {
//    return UniversityViewModel()
//}
