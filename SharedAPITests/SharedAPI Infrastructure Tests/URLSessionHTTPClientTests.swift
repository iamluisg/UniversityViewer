//
//  URLSessionHTTPClientTests.swift
//  SharedAPITests
//
//  Created by Luis Garcia on 11/18/21.
//

import XCTest
import SharedAPI

class URLSessionHTTPClientTests: XCTestCase {
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), HTTPError>
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for url request")
                
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().load(from: URLRequest(url: url), completion: {_ in})
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_postToURL_performsPOSTRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for url request")
                
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "POST")
            exp.fulfill()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        makeSUT().load(from: urlRequest, completion: {_ in})
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_deleteFromURL_performsDELETERequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for url request")
                
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "DELETE")
            exp.fulfill()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        makeSUT().load(from: urlRequest, completion: {_ in})
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_putURL_performsPUTRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for url request")
                
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "PUT")
            exp.fulfill()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        makeSUT().load(from: urlRequest, completion: {_ in})
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let request = URLRequest(url: URL(string: "yurl.com")!)
        let err = NSError(domain: "myDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred"])
        let requestError = HTTPError(code: .unknown,
                                     request: request,
                                     response: nil,
                                     underlyingError: err)

        let receivedError = resultErrorFor(data: nil,
                                           response: nil,
                                           error: requestError) as Error?

        XCTAssertEqual(receivedError?.localizedDescription,
                       requestError.underlyingError?.localizedDescription)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: nonHTTPURLResponse(),
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: anyHTTPURLResponse(),
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nil,
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nil,
                                       error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: nonHTTPURLResponse(),
                                       error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: anyHTTPURLResponse(),
                                       error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nonHTTPURLResponse(),
                                       error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: anyHTTPURLResponse(),
                                       error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nonHTTPURLResponse(),
                                       error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let values = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(values?.data, data)
        XCTAssertEqual(values?.response.url, response.url)
        XCTAssertEqual(values?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helper methods
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 10, userInfo: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {

        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var receivedError: Error?
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("expected failure, got \(result)", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var receivedValues: (Data, HTTPURLResponse)?
        switch result {
        case let .success((data, response)):
            receivedValues = (data, response)
        default:
            XCTFail("expected failure, got \(result)", file: file, line: line)
        }
        
        return receivedValues
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        var response: HTTPClientResult!
        makeSUT().load(from: URLRequest(url: anyURL())) { result in
            response = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return response
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            // request observer is moved from canInit to here because canInit can fire before the request even starts which means the test method will finish its execution before the test even started.
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

