//
//  UniversityLoader.swift
//  UniversitySearch
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation
import SharedAPI

public final class UniversityLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    public func searchUniversities(urlRequest: URLRequest,
                                  completion: @escaping (Result<[University], HTTPError>) -> Void) -> URLSessionDataTask? {
        let task = client.load(from: urlRequest) { [weak self] networkResult in
            guard self != nil else { return }
            switch networkResult {
            case let .success((data, _)):
                do {
                    let remoteUniversities = try JSONDecoder().decode([RemoteUniversity].self, from: data)
                    completion(.success(remoteUniversities.mapAsUniversities()))
                } catch {
                    let err = HTTPError(code: .unknown, request: urlRequest, underlyingError: error)
                    completion(.failure(err))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }

        return task
    }
}

public struct University: Identifiable, Equatable {
    public let id: UUID
    public var alphaTwoCode: String
    public var country: String
    public var domains: [String]
    public var name: String
    public var stateProvince: String?
    public var webPages: [String]
    
    public init(id: UUID, alphaTwoCode: String, country: String, domains: [String], name: String, stateProvince: String?, webPages: [String]) {
        self.id = id
        self.alphaTwoCode = alphaTwoCode
        self.country = country
        self.domains = domains
        self.name = name
        self.stateProvince = stateProvince
        self.webPages = webPages
    }
}

struct RemoteUniversity: Decodable {
    let id = UUID()
    var country: String
    var stateProvince: String?
    var webPages: [String]
    var alphaTwoCode: String
    var name: String
    var domains: [String]

    enum CodingKeys: String, CodingKey {
        case country
        case stateProvince = "state-province"
        case webPages = "web_pages"
        case alphaTwoCode = "alpha_two_code"
        case name
        case domains
    }
}

private extension Array where Element == RemoteUniversity {
    func mapAsUniversities() -> [University] {
        self.map({ University(id: $0.id,
                              alphaTwoCode: $0.alphaTwoCode,
                              country: $0.country,
                              domains: $0.domains,
                              name: $0.name,
                              stateProvince: $0.stateProvince,
                              webPages: $0.webPages) })
    }
}
