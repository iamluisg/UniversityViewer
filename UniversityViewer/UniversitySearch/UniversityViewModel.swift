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
    
    // Passed in variables
    var loader: UniversityLoader
    
    // Initializers
    init(_ loader: UniversityLoader) {
        self.loader = loader
    }
    
    // MARK: - Actions
    func fetchUnis(_ name: String?) {
        var defaultQuery: String = "san"
        if let newQuery = name, !newQuery.isEmpty {
            defaultQuery = newQuery
        }
        
        let request = Endpoint.searchUniversity(defaultQuery).urlRequest
        self.loader.searchUniversities(urlRequest: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(universities):
                    self?.universities = universities
                case let .failure(error):
                    print("request \(error.request) failed with code: \(error.code) and description \(error.localizedDescription)")
                }
            }
        }
    }
}
