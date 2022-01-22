//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation

/// Implementation `URLRequest` according to the `NetworkTask`.
/// iso860 is Ohlulu application policy in API V3.
/// If you don't want use iso8601 to encode date, create your Decode decision for free.
public struct TaskAdapter: NetworkAdapter {
    
    let task: NetworkTask
    let encoder: JSONEncoder
    
    /// - Note: `encoder.dateDecodingStrategy` will be override to `.iso8601`.
    /// If you need to custom dateEncodingStrategy, create your own.
    public init(task: NetworkTask, encoder: JSONEncoder = JSONEncoder()) {
        self.task = task
        self.encoder = encoder
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    public func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        switch task {
        case .simple:
            return request
        case let .urlEncodeEncodable(encodable):
            let encodableObject = AnyEncodableWrapper(encodable)
            return try Result<URLRequest, Error> {
                try URLEncoder(encoder: encoder).encode(encodableObject, with: request)
            }
            .mapError { NetworkError.buildRequestFailed(reason: .urlEncodeFail(error: $0)) }.get()

        case let .jsonEncodeEncodable(encodable):
            let encodableObject = AnyEncodableWrapper(encodable)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try Result<Data, Error> { try encoder.encode(encodableObject) }
                .mapError { NetworkError.buildRequestFailed(reason: .jsonEncodeFail(error: $0)) }.get()
            return request
            
        case let .jsonEncodeDictionary(dictionary, encoder: encoder):
            return try Result<URLRequest, Error> { try encoder.encode(urlRequest: request, withParameters: dictionary) }
                .mapError { NetworkError.buildRequestFailed(reason: .jsonEncodeFail(error: $0)) }.get()
            
        case let .urlEncodeEncodableCombinedDictionary(encodable, dictionary):
            let encodableObject = AnyEncodableWrapper(encodable)
            return try Result<URLRequest, Error> {
                try URLEncoder(encoder: encoder)
                    .encode(encodableObject, queryDictionary: dictionary, with: request)
            }
            .mapError { NetworkError.buildRequestFailed(reason: .urlEncodeFail(error: $0)) }
            .get()
            
        case let .urlEncodeEncodableAndBodyEncodeDictionary(encodable, dictionary):
            
            let encodableObject = AnyEncodableWrapper(encodable)
            request = try Result<URLRequest, Error> {
                try URLEncoder(encoder: encoder).encode(encodableObject, with: request)
            }
            .mapError { NetworkError.buildRequestFailed(reason: .urlEncodeFail(error: $0)) }
            .get()
            
            return try Result<URLRequest, Error> { try HTTPBodyEncoder().encode(urlRequest: request, withParameters: dictionary) }
                .mapError { NetworkError.buildRequestFailed(reason: .jsonEncodeFail(error: $0)) }.get()
        }
    }
}

// MARK: - Helper

private extension TaskAdapter {
    
    struct AnyEncodableWrapper: Encodable {

        private let encodable: Encodable

        init(_ encodable: Encodable) {
            self.encodable = encodable
        }

        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
    }
}
