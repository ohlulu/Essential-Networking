//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation

public struct HTTPBodyEncoder: ParameterEncoder {
    
    public init() {}
    
    public func encode(urlRequest: URLRequest, withParameters parameters: [String: Any]) throws -> URLRequest {
        let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
        var request = urlRequest
        request.httpBody = data
        return request
    }
}
