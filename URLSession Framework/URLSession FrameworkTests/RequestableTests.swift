//
//  Requestable.swift
//  URLSession FrameworkTests
//
//  Created by Matheus Sanada on 18/08/23.
//

import XCTest
@testable import URLSession_Framework

final class RequestableTests: XCTestCase {
    class MockNetworkTask: NetworkTask {
        var baseURL: URLSession_Framework.NetworkBaseURL
        var path: String
        var method: URLSession_Framework.NetworkMethod
        var params: [String : Any]
        var encoding: URLSession_Framework.EncodingMethod
        var headers: [String : String]?
        
        internal init(baseURL: NetworkBaseURL,
                      path: String,
                      method: NetworkMethod,
                      params: [String : Any],
                      encoding: EncodingMethod,
                      headers: [String : String]? = nil) {
            self.baseURL = baseURL
            self.path = path
            self.method = method
            self.params = params
            self.encoding = encoding
            self.headers = headers
        }
    }
    // Mock URLSession for testing
    class MockURLSession: URLSession {
        var dataTaskCalled = false
        
        override func dataTask(with request: URLRequest,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            dataTaskCalled = true
            return URLSessionDataTask()
        }
    }
    
    class MockRequestable: Requestable {
        
    }
    
    // Test Http Method
    func testCreateGetQueryRequest() {
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString)
        let requestable = MockRequestable()
        let request = requestable.createRequest(task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com/mocked")
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func testCreateGetRequest() {
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString)
        let requestable = MockRequestable()
        let request = requestable.createRequest(task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com/")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.allHTTPHeaderFields)
    }

    func testSetPostHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .post,
                                       params: [:],
                                       encoding: .body)

        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com")
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func testSetPutHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .put,
                                       params: [:],
                                       encoding: .body)

        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com")
        XCTAssertEqual(request.httpMethod, "PUT")
    }
    
    func testSetPatchHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .patch,
                                       params: [:],
                                       encoding: .body)

        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com")
        XCTAssertEqual(request.httpMethod, "PATCH")
    }

    func testSetDeleteHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .delete,
                                       params: [:],
                                       encoding: .body)

        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com")
        XCTAssertEqual(request.httpMethod, "DELETE")
    }

    // Test Parameter
    func testSetParametersQueryString() {
        let param = "request"
        let data: [String : String] = ["key": param]
        
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .get,
                                       params: data,
                                       encoding: .queryString)
        
        let requestable = MockRequestable()
        
        var request = requestable.createRequest(task: mockTask)
        requestable.setParameters(to: &request, task: mockTask)
                
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com/mocked?key=request")
    }
    
    func testSetParametersBodyString() {
        let param = "request"
        let data: [String : String] = ["key": param]
        
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .post,
                                       params: data,
                                       encoding: .body)
        let requestable = MockRequestable()
        
        var request = requestable.createRequest(task: mockTask)
        requestable.setParameters(to: &request, task: mockTask)
        

        guard let body = request.httpBody?.dictionary,
                let dict = body as? [String : String] else {
            XCTFail("Body Empty")
            return
        }
        
        XCTAssertEqual(dict, data)
    }
    
    func testSetParametersBodyEmpty() {
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "/path",
                                       method: .post,
                                       params: [:],
                                       encoding: .body,
                                       headers: nil)
        
        let requestable = MockRequestable()
        var request = requestable.createRequest(task: mockTask)

        requestable.setParameters(to: &request, task: mockTask)
        
        XCTAssertNil(request.httpBody)
        // Add more assertions
    }

    func testSetHeadersNoContentType() {
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "/path",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString,
                                       headers: ["Authorization": "Bearer token"])
        
        let requestable = MockRequestable()
        var request = requestable.createRequest(task: mockTask)
        requestable.setHeaders(to: &request, task: mockTask)
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer token")
        XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
        // Add more assertions
    }

    func testSetParametersAndHeaders() {
        let data: [String : String] = ["key": "value"]
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "/path",
                                       method: .post,
                                       params: data,
                                       encoding: .body,
                                       headers: ["Authorization": "Bearer token"])
        let requestable = MockRequestable()
        var request = requestable.createRequest(task: mockTask)
        
        requestable.setParameters(to: &request, task: mockTask)
        requestable.setHeaders(to: &request, task: mockTask)
        requestable.setHTTPMethod(to: &request, task: mockTask)

        guard let body = request.httpBody?.dictionary,
                let dict = body as? [String : String] else {
            XCTFail("Body Empty")
            return
        }
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(dict, data)
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer token")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    // Test Headers
    func testSetHeadersWithContentType() {
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com/")!),
                                       path: "mocked",
                                       method: .post,
                                       params: [:],
                                       encoding: .body,
                                       headers: ["Authorization": "Bearer"])

        let requestable = MockRequestable()
        var request = requestable.createRequest(task: mockTask)

        requestable.setHeaders(to: &request, task: mockTask)
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
}
