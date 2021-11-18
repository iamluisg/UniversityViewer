//
//  HTTPError.swift
//  SharedAPI
//
//  Created by Luis Garcia on 11/18/21.
//

import Foundation

public struct HTTPError: CategorizedError {
    public init(code: Code,
         request: URLRequest,
         response: URLResponse? = nil,
         underlyingError: Error? = nil) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = underlyingError
    }

    var category: ErrorCategory {
        switch code {
        case .connectionLost, .deviceOffline, .callCancelled, .dnsLookupFailed, .timedOut, .unknown, .serverUnavailable:
            return .retryable
        case .resourceNotFound, .urlParsing, .decodingFailed, .encodingFailed, .security,
                .badRequest, .malformedData, .serverCertificate, .urlResponse:
            return .nonRetryable
        case .unauthorized:
            return .requiresLogout
        }
    }

    /// High-level classification of the error
    public let code: Code

    /// HTTPRequest that resulted in this error
    public let request: URLRequest

    /// HTTPResponse (partial or otherwise) that we might have
    public var response: URLResponse?

    /// If we have more information about the error that caused this, stash it here
    public var underlyingError: Error?

    public enum Code {
        case security
        case badRequest
        case connectionLost
        case deviceOffline
        case dnsLookupFailed
        case resourceNotFound
        case urlParsing
        case callCancelled
        case unauthorized
        case decodingFailed
        case encodingFailed
        case malformedData
        case timedOut
        case serverUnavailable
        case serverCertificate
        case unknown
        case urlResponse
    }

    static func urlConversionError(request: URLRequest) -> Self {
        return HTTPError(code: .urlParsing, request: request, response: nil, underlyingError: nil)
    }

    static func bodyEncodingError(request: URLRequest, error: Error?) -> Self {
        return HTTPError(code: .encodingFailed, request: request, response: nil, underlyingError: error)
    }

    static func encodingError(request: URLRequest, error: Error?) -> Self {
        return HTTPError(code: .encodingFailed, request: request, response: nil, underlyingError: error)
    }

    static func lostNetworkConnectionError(request: URLRequest) -> Self {
        return HTTPError(code: .connectionLost, request: request, response: nil, underlyingError: nil)
    }

    static func jsonDecodingError(request: URLRequest, error: Error?) -> Self {
        return HTTPError(code: .decodingFailed, request: request, response: nil, underlyingError: error)
    }

    static func requestCancelled(request: URLRequest) -> Self {
        return HTTPError(code: .callCancelled, request: request, response: nil, underlyingError: nil)
    }
}

extension HTTPError: Equatable {
    public static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        return lhs.code == rhs.code && lhs.request == rhs.request
    }
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self.code {
        case .callCancelled:
            return ""
        case .badRequest:
            return "Bad request"
        case .connectionLost:
            return "Your internet connection was lost"
        case .deviceOffline:
            return "Cannot connect to the network"
        case .dnsLookupFailed:
            return "Error encountered while sending your request"
        case .unauthorized:
            return "You must log in to continue"
        case .decodingFailed, .malformedData:
            return "Error encountered with data returned from the server"
        case .encodingFailed, .urlParsing:
            return "Error encountered while preparing your request"
        case .resourceNotFound:
            return "Could not locate the resource you requested"
        case .security:
            return "An unidentified error occurred"
        case .serverCertificate:
            return "An unidentified error occurred"
        case .serverUnavailable:
            return "We are unable to reach our servers. Please try again in a few minutes."
        case .timedOut:
            return "Response not returned in a timely manner"
        case .unknown:
            return "An unknown error occurred"
        case .urlResponse:
            return "URLResponse value not castable to HTTPURLResponse"
        }
    }
}

public enum ErrorCategory {
    case nonRetryable
    case retryable
    case requiresLogout
}

protocol CategorizedError: Error {
    var category: ErrorCategory { get }
}

extension Error {
    func resolveCategory() -> ErrorCategory {
        guard let categorized = self as? CategorizedError else {
            return .nonRetryable
        }
        return  categorized.category
    }
}


public func makeErr(request: URLRequest,
             data: Data?,
             urlResponse: URLResponse?,
             responseError: Error) -> HTTPError {

    guard let urlResponse = urlResponse as? HTTPURLResponse else {
        return HTTPError(code: .unknown,
                         request: request,
                         response: nil,
                         underlyingError: responseError)
    }

    if let urlError = responseError as? URLError {
        #if DEBUG
            print("The error code is \(urlError)")
        #endif
        let code: HTTPError.Code
        switch urlError.code {
            case .appTransportSecurityRequiresSecureConnection: code = .security
            case .badServerResponse: code = .malformedData
            case .badURL: code = .urlParsing
            case .cannotDecodeRawData, .cannotDecodeContentData, .cannotParseResponse: code = .decodingFailed
            case .unsupportedURL: code = .unknown
            case .cannotFindHost: code = .serverUnavailable
            case .cannotConnectToHost: code = .connectionLost
            case .userAuthenticationRequired: code = .unauthorized
            case .cancelled: code = .callCancelled
            case .networkConnectionLost: code = .connectionLost
            case .timedOut: code = .timedOut
            case .resourceUnavailable: code = .resourceNotFound
            case .notConnectedToInternet: code = .deviceOffline
            case .fileDoesNotExist: code = .resourceNotFound
            case .downloadDecodingFailedMidStream: code = .decodingFailed
            case .downloadDecodingFailedToComplete: code = .decodingFailed
            case .dnsLookupFailed: code = .dnsLookupFailed
            case .dataNotAllowed: code = .callCancelled
            case .serverCertificateUntrusted,
                 .serverCertificateHasBadDate,
                 .serverCertificateNotYetValid: code = .serverCertificate
            default: code = .unknown
        }

        return HTTPError(code: code,
                         request: request,
                         response: urlResponse,
                         underlyingError: urlError)
    } else {
        // an error, but not a URL error
        return HTTPError(code: .unknown,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
    }
}

public func validateResponse(request: URLRequest,
                      responseData: Data?,
                      urlResponse: URLResponse?,
                      responseError: Error?) -> Result<(Data, HTTPURLResponse), HTTPError> {
    
    guard let urlResponse = urlResponse as? HTTPURLResponse else {
        let error = HTTPError(code: .unknown,
                         request: request,
                         response: nil,
                         underlyingError: responseError)
        return .failure(error)
    }

    guard let data = responseData else {
        let error = HTTPError(code: .malformedData,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    }
    
    switch urlResponse.statusCode {
    case 200:
        return .success((data, urlResponse))
    case 401, 403:
        let error = HTTPError(code: .unauthorized,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    case 404:
        let error = HTTPError(code: .resourceNotFound,
                              request: request,
                              response: urlResponse,
                              underlyingError: responseError)
        return .failure(error)
    case 500:
        let error = HTTPError(code: .serverUnavailable,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    case 400:
        let error = HTTPError(code: .badRequest,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    case 408:
        let error = HTTPError(code: .timedOut,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    default:
        let error = HTTPError(code: .unknown,
                         request: request,
                         response: urlResponse,
                         underlyingError: responseError)
        return .failure(error)
    }
}
