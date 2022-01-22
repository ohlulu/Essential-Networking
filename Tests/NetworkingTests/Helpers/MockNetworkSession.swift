//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Foundation
import Networking

final class MockNetworkSession: NetworkSession {
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    struct URLSessionTaskWrapper: NetworkCancelable {
        let wrapped: URLSessionTask
        func cancelRequest() {
            wrapped.cancel()
        }
    }
    
    public func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancelable {
        let task = session.dataTask(with: request) { data, URLResponse, error in
            completion(data, URLResponse, error)
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
