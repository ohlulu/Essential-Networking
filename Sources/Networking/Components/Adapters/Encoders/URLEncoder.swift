//
//  URLEncoder.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/17.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

/// URLEncoder encode a parameter(Encodable) to a query string, and return a new `URLRequest` with the query string.
/// Align `JSONEncoder` naming, so nothing else protocol.
///     1. Use `JSONEncoder` encode to `Data`
///     2. Serialized the data to `[String: Any]`, return `Error` if failed.
///     3. query `[String: Any]` and escape
struct URLEncoder {

    enum Error: Swift.Error {
        case undefine
    }
    
    let encoder: JSONEncoder

    /// Encode parameter into a request's url
    /// - Parameters:
    ///   - parameters: Encodable parameter
    ///   - request: A request URL to been encode.
    /// - Returns: The encoded `URLRequest`.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, with request: URLRequest) throws -> URLRequest {
        // can implementation with third-party framework at here

        let data = try encoder.encode(parameters)
        guard
            let url = request.url,
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            throw Error.undefine // should not error.
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let percentEncodedQuery = (components?.percentEncodedQuery.map { $0 + "&" } ?? "") + query(dictionary, allowed: .urlQueryAllowed)
        components?.percentEncodedQuery = percentEncodedQuery

        var newRequest = request
        newRequest.url = components?.url ?? url
        return newRequest
    }
    
    // TODO: Refactor needed.
    /// Encode encodable parameter combined with dictionary into a request's url
    /// - Parameters:
    ///   - parameters: Encodable parameter
    ///   - queryDictionary: dictionary to be append to url query
    ///   - request: A request URL to been encode.
    /// - Returns: The encoded `URLRequest`.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, queryDictionary: [String: String], with request: URLRequest) throws -> URLRequest {
        // can implementation with third-party framework at here

        let data = try encoder.encode(parameters)
        guard
            let url = request.url,
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            throw Error.undefine // should not error.
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let dictionaryToQuery: [String: Any] = dictionary.merging(queryDictionary) { current, _ in
            return current
        }
        let percentEncodedQuery = (components?.percentEncodedQuery.map { $0 + "&" } ?? "") + query(dictionaryToQuery, allowed: .urlQueryAllowed)
        components?.percentEncodedQuery = percentEncodedQuery

        var newRequest = request
        newRequest.url = components?.url ?? url
        return newRequest
    }
}

// MARK: - Helper method

// Reference: https://github.com/line/line-sdk-ios-swift/blob/master/LineSDK/LineSDK/Networking/Client/ParametersAdapter.swift
private extension URLEncoder {

    func query(_ parameters: [String: Any], allowed: CharacterSet = .urlQueryAllowed) -> String {
        return parameters
            .reduce([]) { result, kvp in // kvp = key value pair
                result + queryComponents(fromKey: kvp.key, value: kvp.value, allowed: allowed)
            }
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
    }

    func queryComponents(
        fromKey key: String,
        value: Any,
        allowed: CharacterSet = .urlQueryAllowed
    ) -> [(String, String)] {

        var components: [(String, String)] = []

        // TODO: 沒有處理 dictionary 的情況，日後有用到再補上
        if let array = value as? [Any] {
            let value = array.map { "\($0)" }.joined(separator: ",")
            components.append((escape(key), escape("\(value)", allowed: allowed)))
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(value.boolValue ? "1" : "0")))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(bool ? "1" : "0")))
        } else {
            components.append((escape(key), escape("\(value)", allowed: allowed)))
        }

        return components
    }

    func escape(_ string: String, allowed: CharacterSet = .urlQueryAllowed) -> String {

        // Reserved characters defined by RFC 3986
        // Reference: https://www.ietf.org/rfc/rfc3986.txt
        // ⚠️ https://developer.apple.com/documentation/foundation/urlcomponents/1780305-percentencodedquery
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

private extension NSNumber {
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
