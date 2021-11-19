//
//  Endpoint.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation

let baseScheme: String = "http"
let baseHost: String = "universities.hipolabs.com"

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = baseScheme
        components.host = baseHost
        components.path = "/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Invalid url components \(components)")
        }

        return url
    }
    
    var urlRequest: URLRequest {
        return URLRequest(url: self.url)
    }
}

extension Endpoint {
    static func searchUniversity(_ query: String) -> Self {
        let queryItem = URLQueryItem(name: "name", value: query)
        return Endpoint(path: "search", queryItems: [queryItem])
    }
}
