//
//  UniversityViewModel.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation
import Combine
import UniversitySearch

class UniversityViewModel: ObservableObject {

    // Combine variables
    @Published private(set) var universities: [University] = []
    let buttonPressedSubject = PassthroughSubject<Bool, Never>()

    // Binded variables
    var isTapped: Bool = false {
        willSet {
            buttonPressedSubject.send(isTapped)
        }
    }
    
    // Passed in variables
    var loader: UniversityLoader
    
    // Initializers
    init(_ loader: UniversityLoader) {
        self.loader = loader
    }
    
    // MARK: - Actions
    func fetchUnis(_ name: String?) {
        let request = Endpoint.searchUniversity(name ?? "").urlRequest
        self.loader.searchUniversities(urlRequest: request) { [weak self] result in
            switch result {
            case let .success(universities):
                self?.universities = universities
                print("got the unis \(universities)")
            case let .failure(error):
                print("request \(error.request) failed with code: \(error.code) and description \(error.localizedDescription)")
            }
        }
    }
    
    func buttonPressed() {
        self.isTapped.toggle()
    }
}
