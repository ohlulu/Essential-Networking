//
//  ParameterEncoder.swift
//  Networling
//
//  Created by Ohlulu on 2021/2/4.
//  Copyright © 2021 Ohlulu. All rights reserved.
//

import Foundation

/// Encode `Parameters: [String: Any]` to a request.
public protocol ParameterEncoder {
    func encode(urlRequest: URLRequest, withParameters parameters: [String: Any]) throws -> URLRequest
}
