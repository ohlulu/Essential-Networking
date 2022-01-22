//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation

/// Last decision, decode data to a `Request.Entity` object.
public class DecodeDecision: NetworkDecision {

    let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    public func shouldApply<R: NetworkRequest>(request: R, data: Data, response: HTTPURLResponse) -> Bool {
        return true
    }

    public func apply<R: NetworkRequest>(
        request: R,
        data: Data,
        response: HTTPURLResponse,
        action: @escaping (NetworkDecisionAction<R>) -> Void
    ) {

        do {
            let model = try decoder.decode(R.Entity.self, from: data)
            action(.done(model))
        } catch {
            let reason = NetworkError.ResponseErrorReason.decodeFailed(error)
            action(.stop(NetworkError.responseFailed(reason: reason)))
        }
    }
}
