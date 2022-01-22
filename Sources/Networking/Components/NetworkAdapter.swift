//
//  NetworkAdapter.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/5.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

/// Adapts a `URLRequest`
public protocol NetworkAdapter {

    /// Adapts an input `URLRequest` and return a modified object.
    ///
    /// - Parameter request: The request to be adapted.
    /// - Returns: The modified `URLRequest` object.
    /// - Throws: An error during the adapting process.
    func adapted(_ request: URLRequest) throws -> URLRequest
}
