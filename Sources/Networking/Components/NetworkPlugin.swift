//
//  NetworkPlugin.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/5.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

/// Plugin receives callbacks wherever a request is sent or received.
public protocol NetworkPlugin: AnyObject {
    func willSend<R: NetworkRequest>(_ request: R)
    func didReceive(_ response: NetworkResponse)
}

public extension NetworkPlugin {

    /// Called before sending.
    func willSend<R: NetworkRequest>(_ request: R) {}

    /// Called after response has been received.
    func didReceive(_ response: NetworkResponse) {}
}
