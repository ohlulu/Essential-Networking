//
//  NetworkRequest.swift
//  Networling
//
//  Created by Ohlulu on 2020/11/6.
//  Copyright © 2020 Ohlulu. All rights reserved.
//

import Foundation

public protocol NetworkRequest {

    associatedtype Entity: Decodable

    var baseURL: URL { get }

    var path: String { get }

    var method: HTTPMethod { get }

    var headers: [String: String] { get }

    var task: NetworkTask { get }

    var adapters: [NetworkAdapter] { get }

    var decisions: [NetworkDecision] { get }

    var plugins: [NetworkPlugin] { get }
}
