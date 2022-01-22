//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation

/// Adapts header field to a request.
public struct HeaderAdapter: NetworkAdapter {

    let data: [String: String]

    public init(data: [String: String]) {
        self.data = data
    }

    public func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        data.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
