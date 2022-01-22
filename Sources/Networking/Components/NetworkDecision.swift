//
//  NetworkDecision.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/5.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

/// The result of response `handle` method.
/// - next: continue next decision with the response's `Data` and `HTTPURLResponse`.
/// - restart: restart: Restart the whole request with the given decisions.
/// - stop: Stop handling process and report an error.
/// - done: A final result of all decisions and report a value
public enum NetworkDecisionAction<R: NetworkRequest> {
    case next(Data, HTTPURLResponse)
    case restart([NetworkDecision])
    case stop(NetworkError)
    case done(R.Entity)
}
    
public protocol NetworkDecision: AnyObject { // easier equatable

    func shouldApply<R: NetworkRequest>(request: R, data: Data, response: HTTPURLResponse) -> Bool

    func apply<R: NetworkRequest>(
        request: R,
        data: Data,
        response: HTTPURLResponse,
        action: @escaping (NetworkDecisionAction<R>) -> Void
    )
}
