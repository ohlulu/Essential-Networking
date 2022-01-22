//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation

/// Adapts HTTP method to a request.
public struct MethodAdapter: NetworkAdapter {

    let method: HTTPMethod
    
    public init(method: HTTPMethod) {
        self.method = method
    }

    public func adapted(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpMethod = method.rawValue

        switch method {
        case .get:
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        case .post:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
