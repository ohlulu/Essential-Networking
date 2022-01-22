//
//  Copyright © 2022 Ohlulu. All rights reserved.
//

import Networking
import XCTest

class NetworkingService_Tests: XCTestCase {
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    func test_cancelRequest_cancelTheURLRequest() {
        let request = AnyRequestStub()
        let exp = XCTestExpectation(description: #function)
        let sut = makeSUT()
        var receivedError: NSError?
        let task = sut.send(request) { result in
            switch result {
            case let .failure(networkError):
                if case let .responseFailed(.URLSessionError(error)) = networkError {
                    receivedError = error as NSError
                }
            case .success:
                break
            }
            
            exp.fulfill()
        }
        task?.cancelRequest()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    func test_send_performsRequestWithURL() {
        let request = AnyRequestStub(baseURL: anyURL())
        let exp = XCTestExpectation(description: #function)
        let sut = makeSUT()

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, anyURL())
            exp.fulfill()
        }
        
        sut.send(request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_send_adaptedGETMethodWithRequest() {
        let sut = makeSUT()
        let exp1 = XCTestExpectation(description: #function)
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            exp1.fulfill()
        }
        sut.send(AnyRequestStub(method: .get)) { _ in }
        wait(for: [exp1], timeout: 1.0)
    }
    
    func test_send_adaptedPOSTMethodWithRequest() {
        let exp = XCTestExpectation(description: #function)
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "POST")
            exp.fulfill()
        }
        makeSUT().send(AnyRequestStub(method: .post)) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_send_adaptedHeaderWithRequest() {
        let request = AnyRequestStub(headers: ["a key": "a value"])
        let exp = XCTestExpectation(description: #function)
        let sut = makeSUT()

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.allHTTPHeaderFields?["a key"], "a value")
            exp.fulfill()
        }
        
        sut.send(request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_send_adaptedParametersInURL() {
        let parameters = ParameterStub()
        let request = AnyRequestStub(method: .get, task: .urlEncodeEncodable(parameters))
        let exp = XCTestExpectation(description: #function)
        let sut = makeSUT()

        URLProtocolStub.observeRequests { request in
            let queryMap = request.url?.components()?
                .percentEncodedQueryItems?
                .reduce(into: [String: String]()) {
                    $0[$1.name] = $1.value
                }
            // https://www.urlencoder.org/
            XCTAssertEqual(queryMap?["string"], "Ohlulu")
            XCTAssertEqual(queryMap?["stringZH"], "%E4%B8%AD%E6%96%87")
            XCTAssertEqual(queryMap?["int"], "10")
            XCTAssertEqual(queryMap?["bool"], "1")
            XCTAssertEqual(queryMap?["array"], "a1%2Ca2")
            
            exp.fulfill()
        }
        
        sut.send(request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_send_adaptedParametersInBody() {
        let parameters = ParameterStub()
        let request = AnyRequestStub(method: .post, task: .jsonEncodeEncodable(parameters))
        let exp = XCTestExpectation(description: #function)
        let sut = makeSUT()
        URLProtocolStub.observeRequests { request in
            // Nil
            let httpBody = try! JSONDecoder().decode(ParameterStub.self, from: request.httpBodyData!)
            XCTAssertEqual(httpBody.string, "Ohlulu")
            XCTAssertEqual(httpBody.stringZH, "中文")
            XCTAssertEqual(httpBody.int, 10)
            XCTAssertEqual(httpBody.bool, true)
            XCTAssertEqual(httpBody.array, ["a1", "a2"])
            
            exp.fulfill()
        }
        
        sut.send(request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helpers

private extension NetworkingService_Tests {
    
    func makeSUT() -> NetworkService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = MockNetworkSession(session: URLSession(configuration: configuration))
        let sut = NetworkService(session: session)
        trackMemoryLeaks(sut)
        return sut
    }
}

private extension NetworkingService_Tests {
    
    struct AnyDecodable: Decodable {}
    typealias AnyRequestStub = RequestStub<AnyDecodable>
}

private extension NetworkingService_Tests {
    
    struct ParameterStub: Codable {
        var string: String = "Ohlulu"
        var stringZH: String = "中文"
        var int: Int = 10
        var bool: Bool = true
        var array = ["a1", "a2"]
    }
    
    struct RequestStub<Response: Decodable>: NetworkRequest {
        
        typealias Entity = Response
    
        let baseURL: URL
        let path: String
        let method: HTTPMethod
        let headers: [String: String]
        let task: NetworkTask
        var adapters: [NetworkAdapter] {
            [
                MethodAdapter(method: method),
                HeaderAdapter(data: headers),
                TaskAdapter(task: task)
            ]
        }

        let decisions: [NetworkDecision]
        let plugins: [NetworkPlugin]
        
        init(
            baseURL: URL = anyURL(),
            path: String = "",
            method: HTTPMethod = .get,
            headers: [String: String] = [:],
            task: NetworkTask = .simple,
            decisions: [NetworkDecision] = [],
            plugins: [NetworkPlugin] = []
        ) {
            self.baseURL = baseURL
            self.path = path
            self.method = method
            self.headers = headers
            self.task = task
            self.decisions = decisions
            self.plugins = plugins
        }
    }
}

private func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

extension XCTestCase {
    
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

private extension URL {
    
    func components() -> URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}
