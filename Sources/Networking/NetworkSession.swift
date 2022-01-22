//
//  NetworkSession.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/6.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

/// Provide request-able, response-able method
public protocol NetworkSession {

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancelable
}
