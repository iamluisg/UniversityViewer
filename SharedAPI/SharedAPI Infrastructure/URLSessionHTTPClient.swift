//
//  URLSessionHTTPClient.swift
//  SharedAPI
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    @discardableResult
    public func load(from urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), HTTPError>) -> Void) -> URLSessionDataTask? {
        #if DEBUG
        print("url request is \(urlRequest)")
        #endif
        
        let dataTask = session.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                let httpError = HTTPError(code: .unknown,
                                          request: urlRequest,
                                          response: urlResponse,
                                          underlyingError: error)
                completion(.failure(httpError))
            } else {
                switch validateResponse(request: urlRequest, responseData: data, urlResponse: urlResponse, responseError: error) {
                case let .success(validatedResponse):
                    completion(.success(validatedResponse))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
        dataTask.resume()

        return dataTask
    }
}
