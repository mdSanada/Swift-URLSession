//
//  Requestable.swift
//  URLSession FrameworkTests
//
//  Created by Matheus Sanada on 18/08/23.
//

import XCTest
@testable import URLSession_Framework

final class RequestableTests: XCTestCase {
    // Mock NetworkTask for testing
    enum MockNetworkTask: NetworkTask {
        case get
        case getQuey(String)
        case post(String)
        case authPost(String)
        case put(String)
        case patch(String)
        case delete(String)
        
        var baseURL: NetworkBaseURL {
            return .url(URL(string: "https://mock.sanada.com")!)
        }
        
        var path: String {
            switch self {
            case .get:
                return ""
            case .getQuey:
                return "mocked"
            case .post:
                return "mockedPost"
            case .authPost:
                return "mockedAuthPost"
            case .put:
                return "mockedPut"
            case .patch:
                return "mockedPatch"
            case .delete:
                return "mockedDelete"
            }
        }
        
        var method: NetworkMethod {
            switch self {
            case .getQuey, .get:
                return .get
            case .post, .authPost:
                return .post
            case .put:
                return .put
            case .patch:
                return .patch
            case .delete:
                return .delete
            }
        }
        
        var params: [String: Any] {
            switch self {
            case .get:
                return [:]
            case .getQuey(let param):
                return ["key": param]
            case .post(let param):
                return ["key": param]
            case .authPost(let param):
                return ["key": param]
            case .put(let param):
                return ["key": param]
            case .patch(let param):
                return ["key": param]
            case .delete(let param):
                return ["key": param]
            }
        }
        
        var encoding: EncodingMethod {
            switch self {
            case .getQuey, .get:
                return .queryString
            case .post, .authPost, .put, .patch, .delete:
                return .body
            }
        }
        
        var headers: [String: String]? {
            switch self {
            case .get:
                return nil
            case .getQuey(let header):
                return ["header": header]
            case .post(let header):
                return ["header": header]
            case .put(let header):
                return ["header": header]
            case .patch(let header):
                return ["header": header]
            case .delete(let header):
                return ["header": header]
            case .authPost(let header):
                return ["header": header]
            }
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
    
    func testCreateGetQueryRequest() {
        let mockTask = MockNetworkTask.getQuey("request")
        let requestable = MockRequestable()
        let request = requestable.createRequest(task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com/mocked")
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func testCreateGetRequest() {
        let mockTask = MockNetworkTask.get
        let requestable = MockRequestable()
        let request = requestable.createRequest(task: mockTask)
        
        XCTAssertEqual(request.url?.absoluteString, "https://mock.sanada.com/")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.allHTTPHeaderFields)
    }

    func testSetPostHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask.post("request")
        
        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func testSetPutHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask.put("request")
        
        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.httpMethod, "PUT")
    }
    
    func testSetPatchHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask.patch("request")
        
        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.httpMethod, "PATCH")
    }

    func testSetDeleteHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let mockTask = MockNetworkTask.delete("request")
        
        let requestable = MockRequestable()
        requestable.setHTTPMethod(to: &request, task: mockTask)
        
        XCTAssertEqual(request.httpMethod, "DELETE")
    }

    func testSetParametersQueryString() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let param = "request"
        let mockTask = MockNetworkTask.post(param)
        let requestable = MockRequestable()
        requestable.setParameters(to: &request, task: mockTask)
        
        let data: [String : String] = ["key": param]
        
        guard let body = request.httpBody?.dictionary,
                let dict = body as? [String : String] else {
            XCTFail("Body Empty")
            return
        }
        
        XCTAssertEqual(dict, data)
    }

    func testSetHeadersWithContentType() {
        var request = URLRequest(url: URL(string: "https://mock.sanada.com")!)
        let param = "request"
        let mockTask = MockNetworkTask.post(param)
        
        let requestable = MockRequestable()
        requestable.setHeaders(to: &request, task: mockTask)
        
        XCTAssertEqual(request.allHTTPHeaderFields?["header"], param)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
}
