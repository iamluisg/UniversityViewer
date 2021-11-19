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
        self.fetchUnis(nil)
    }
    
    // MARK: - Actions
    func fetchUnis(_ name: String?) {
        
    }
    
    func buttonPressed() {
        self.isTapped.toggle()
    }
}

