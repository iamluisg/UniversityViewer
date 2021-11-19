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
