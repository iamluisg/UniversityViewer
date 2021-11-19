//
//  UniversityViewModelTests.swift
//  UniversityViewerTests
//
//  Created by Luis Garcia on 11/18/21.
//

import XCTest
@testable import UniversityViewer
import UniversitySearch
import SharedAPI

class UniversityViewModelTests: XCTestCase {
    
    func test_init_doesNotMakeAPICall() {
        let client = API()
        let loader = UniversityLoaderSpy(client: client)
        
        _ = UniversityViewModel(loader)
        
        XCTAssertEqual(loader.requestsMade.count, 0)
    }
    
    func test_fetchUniversities_makesCall() {
        let client = API()
        let loader = UniversityLoaderSpy(client: client)
        let viewModel = UniversityViewModel(loader)
        
        viewModel.fetchUnis("har")
        
        XCTAssertEqual(loader.requestsMade.count, 1)
    }
    
    func test_toBeWritten() {
        //        loader.searchUniversities(urlRequest: makeURLRequest()) { result in
        //            receivedResult = result
        //            exp.fulfill()
        //        }
        //
        //        wait(for: [exp], timeout: 1.0)
        //
        //        switch receivedResult {
        //        case let .success(universities):
        //            XCTAssertEqual(universities.first?.country, "Canada")
        //            XCTAssertEqual(universities.first?.name, "Montreal University")
        //        case let .failure(error):
        //            XCTFail("expected success but got \(error)")
        //        case .none:
        //            XCTFail("expected success but got none case")
        //        }
    }
    
    private var aURL: URL {
        return URL(string: "https://a-given-url.com")!
    }
    
    func makeURLRequest() -> URLRequest {
        return URLRequest(url: aURL)
    }
}

class UniversityLoaderSpy: UniversityLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    var requestsMade: [URLRequest] = []
    
    func searchUniversities(urlRequest: URLRequest,
                                  completion: @escaping (Result<[University], HTTPError>) -> Void) -> URLSessionDataTask? {
        requestsMade.append(urlRequest)
        return nil
    }
}

private class API: HTTPClient {
    func load(from urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), HTTPError>) -> Void) -> URLSessionDataTask? {
        let result: Result<(Data, HTTPURLResponse), HTTPError> = .success((makeUniversityData(), HTTPURLResponse()))
        completion(result)
        return nil
    }
    
    private func makeUniversityData() -> Data {
        let university = makeUniversityItem(id: UUID(), country: "Canada", name: "Montreal University")
        let json = [university.json]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeUniversityItem(id: UUID, alphaTwoCode: String = "AT", country: String, domains: [String] = [], name: String, stateProvince: String? = nil, webPages: [String] = []) -> (model: University, json: [String: Any]) {
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "alpha_two_code": alphaTwoCode,
            "country": country,
            "domains": domains,
            "name": name,
            "state-province": stateProvince as Any,
            "web_pages": webPages
        ]

        let jsonItem = json.compactMapValues{$0}
        let item = University(id: id,
                              alphaTwoCode: alphaTwoCode,
                              country: country,
                              domains: domains,
                              name: name,
                              stateProvince: stateProvince,
                              webPages: webPages)
        return (item, jsonItem)
    }
}
