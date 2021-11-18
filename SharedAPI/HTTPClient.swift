//
//  HTTPClient.swift
//  SharedAPI
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation

public protocol HTTPClient {
    @discardableResult
    func load(from urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), HTTPError>) -> Void) -> URLSessionDataTask?
}
