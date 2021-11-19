//
//  UniversityLoaderTests.swift
//  UniversitySearchTests
//
//  Created by Luis Garcia on 11/18/21.
//

import XCTest
import UniversitySearch
import SharedAPI

class UniversityLoaderTests: XCTestCase {
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), HTTPError>
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_searchUniversities_requestsDataFromURL() {
        let (sut, client)  = makeSUT()
        let requestURL = makeURLRequest()
        sut.searchUniversities(urlRequest: requestURL) { _ in }
        XCTAssertEqual(client.requestedURLs, [requestURL])
    }

    func test_searchUniversitiesTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let urlRequest = makeURLRequest()
        sut.searchUniversities(urlRequest: urlRequest) { _ in }
        sut.searchUniversities(urlRequest: urlRequest) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_searchUniversities_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(anyHTTPError())) {
            let clientError = anyHTTPError() //NSError(domain: "test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        }
    }
    
    func test_searchUniversities_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(anyHTTPError(aURL))) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_searchUniversities_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(anyHTTPError())) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_searchUniversities_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let itemOne = makeUniversityItem(id: UUID(), country: "Korea", name: "Chungwoon University")
        let itemTwo = makeUniversityItem(id: UUID(), country: "Mexico", name: "Universidad de Monterrey")
        let jsss = [itemOne.json, itemTwo.json]
        let expectedResult: Result<[University], HTTPError> = .success([itemOne.model, itemTwo.model])
        
        let exp = expectation(description: "await completion")
        
        var receivedResult: Result<[University], HTTPError>?
        sut.searchUniversities(urlRequest: makeURLRequest()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        let data = try! JSONSerialization.data(withJSONObject: jsss)
        client.complete(withStatusCode: 200, data: data)
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedResult), .success(expectedResult)):
            XCTAssertEqual(receivedResult.first?.name, expectedResult.first?.name)
            XCTAssertEqual(receivedResult.first?.country, expectedResult.first?.country)
            return
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError, expectedError)
        default:
            XCTFail("expected result \(expectedResult) got \(String(describing: receivedResult))")
        }
    }

    func test_load_doesNotDeliverResultAfterTheSUTInstanceHasBeenDeallocated() {
        let urlRequest = URLRequest(url: aURL)
        let client = HTTPClientSpy()
        var sut: UniversityLoader? = UniversityLoader(client: client)
        
        var capturedResults = [Result<[University], HTTPError>]()
        sut?.searchUniversities(urlRequest: urlRequest) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
   
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: UniversityLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = UniversityLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure( _ error: HTTPError) -> HTTPClientResult {
        return .failure(error)
    }
    
    private func expect<T>(_ sut: UniversityLoader,
                        toCompleteWith expectedResult: Result<T, HTTPError>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        sut.searchUniversities(urlRequest: makeURLRequest()) { receivedResult in
            self.compare(receivedResult: receivedResult, to: expectedResult, file: file, line: line)
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func compare<T: Equatable, X>(receivedResult: Result<T, HTTPError>,
                            to expectedResult: Result<X, HTTPError>,
                            file: StaticString = #filePath, line: UInt = #line) {
        switch (receivedResult, expectedResult) {
        case (.success(let received), .success(let expectedResult)):
            XCTAssertEqual(received, expectedResult as! T)
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError, expectedError)
        default:
            XCTFail("expected result \(expectedResult) got \(receivedResult)", file: file, line: line)
        }
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages = [(urlRequest: URLRequest, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map { $0.urlRequest }
        }

        func complete(with error: HTTPError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].urlRequest.url!,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
        func load(from urlRequest: URLRequest, completion: @escaping (HTTPClientResult) -> Void) -> URLSessionDataTask? {
            messages.append((urlRequest, completion))
            return nil
        }
    }
    private var aURL: URL {
        return URL(string: "https://a-given-url.com")!
    }
    
    func makeURLRequest() -> URLRequest {
        return URLRequest(url: aURL)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
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

    private func anyHTTPError(_ url: URL? = nil) -> HTTPError {
        var urlForRequest: URL!
        if let url = url {
            urlForRequest = url
        } else {
            urlForRequest = aURL
        }
        let request = URLRequest(url: urlForRequest)
        return HTTPError(code: .unknown,
                         request: request,
                         response: nil,
                         underlyingError: nil)
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
