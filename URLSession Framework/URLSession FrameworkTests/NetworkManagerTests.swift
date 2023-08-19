//
//  NetworkManagerTests.swift
//  URLSession FrameworkTests
//
//  Created by Matheus Sanada on 19/08/23.
//

import XCTest
@testable import URLSession_Framework

final class NetworkManagerTests: XCTestCase {
    struct MockNetworkModel: Codable {
        let value: String
    }
    
    // Mock NetworkTask for testing
    struct MockNetworkTask: NetworkTask {
        var baseURL: NetworkBaseURL
        var path: String
        var method: NetworkMethod
        var params: [String: Any]
        var encoding: EncodingMethod
        var headers: [String: String]?
    }
    
    // MockRequestable for testing NetworkManager
    class MockRequestable: Requestable {
    }
    
    // Mock URLSession for testing
    class MockURLSession: URLSession {
        var dataTaskCalled = false
        var dataTaskHandler: ((URLRequest,
                               @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)?
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            dataTaskCalled = true
            
            if let dataTaskHandler = dataTaskHandler {
                return dataTaskHandler(request, completionHandler)
            }
            
            return super.dataTask(with: request, completionHandler: completionHandler)
        }
    }

    // Mock URLSessionDataTask for testing
    class MockURLSessionDataTask: URLSessionDataTask {
        enum MockResult {
            case success
            case error
            case mapError
        }
        
        let completionHandler: (Data?, URLResponse?, Error?) -> Void
        let mockResult: MockResult
        
        init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
                                           mockResult: MockResult) {
            self.completionHandler = completionHandler
            self.mockResult = mockResult
            super.init()
        }
        
        override func resume() {
            switch mockResult {
            case .success:
                success()
            case .error:
                error()
            case .mapError:
                onMapError()
            }
        }
        
        func success() {
            let mockModel = MockNetworkModel(value: "Mock Value")
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(mockModel) {
                let response = HTTPURLResponse(url: URL(string: "https://mock.sanada.com")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)
                completionHandler(data, response, nil)
            } else {
                completionHandler(nil,
                                  nil,
                                  NSError(domain: "MockURLSessionDataTask",
                                          code: -1,
                                          userInfo: nil))
            }
        }
        
        func error() {
            completionHandler(nil,
                              nil,
                              NSError(domain: "MockURLSessionDataTask",
                                      code: 400,
                                      userInfo: nil))
        }
        
        func onMapError() {
            let data = "Mock Data".data(using: .utf8)
            let response = HTTPURLResponse(url: URL(string: "https://mock.sanada.com")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)
            completionHandler(data, response, nil)
        }
    }
    
    func testRequest() {
        let mockSession = MockURLSession()
        var mockDataTask: MockURLSessionDataTask?
        mockSession.dataTaskHandler = { request, completionHandler in
            mockDataTask = MockURLSessionDataTask(completionHandler: completionHandler,
                                                  mockResult: .success)
            return mockDataTask!
        }
        
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com")!),
                                       path: "/path",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString,
                                       headers: nil)
        
        var isLoading: Bool?
        var onSuccessResponse: MockNetworkModel?
        var onErrorCalled = false
        var onMapErrorCalled = false
        
        let networkManager = NetworkManager<MockNetworkTask>()
        networkManager.request(mockTask,
                               map: MockNetworkModel.self,
                               session: mockSession,
                               onLoading: { loading in
                                   isLoading = loading
                               },
                               onSuccess: { response in
                                   onSuccessResponse = response
                               },
                               onError: { error in
                                   onErrorCalled = true
                               },
                               onMapError: { data in
                                    onMapErrorCalled = true
                               })
        
        XCTAssertTrue(isLoading!)
        
        XCTAssertTrue(mockSession.dataTaskCalled)
        
        mockDataTask?.resume()
        
        XCTAssertNotNil(onSuccessResponse)
        XCTAssertFalse(onErrorCalled)
        XCTAssertFalse(onMapErrorCalled)
        
        XCTAssertFalse(isLoading!)

        XCTAssertEqual(onSuccessResponse?.value, "Mock Value")
    }
    
    func testErrorRequest() {
        let mockSession = MockURLSession()
        var mockDataTask: MockURLSessionDataTask?
        mockSession.dataTaskHandler = { request, completionHandler in
            mockDataTask = MockURLSessionDataTask(completionHandler: completionHandler,
                                                  mockResult: .error)
            return mockDataTask!
        }
        
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com")!),
                                       path: "/path",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString,
                                       headers: nil)
        
        var isLoading: Bool?
        var onSuccessResponse: MockNetworkModel? = nil
        var onErrorCalled = false
        var onMapErrorCalled = false
        
        let networkManager = NetworkManager<MockNetworkTask>()
        networkManager.request(mockTask,
                               map: MockNetworkModel.self,
                               session: mockSession,
                               onLoading: { loading in
                                   isLoading = loading
                               },
                               onSuccess: { response in
                                   onSuccessResponse = response
                               },
                               onError: { error in
                                   onErrorCalled = true
                               },
                               onMapError: { data in
                                    onMapErrorCalled = true
                               })
        
        XCTAssertTrue(isLoading!)
        
        XCTAssertTrue(mockSession.dataTaskCalled)
        
        mockDataTask?.resume()
        
        XCTAssertNil(onSuccessResponse)
        
        XCTAssertTrue(onErrorCalled)
        XCTAssertFalse(onMapErrorCalled)
        
        XCTAssertFalse(isLoading!)
    }

    func testOnMapErrorRequest() {
        let mockSession = MockURLSession()
        var mockDataTask: MockURLSessionDataTask?
        mockSession.dataTaskHandler = { request, completionHandler in
            mockDataTask = MockURLSessionDataTask(completionHandler: completionHandler,
                                                  mockResult: .mapError)
            return mockDataTask!
        }
        
        let mockTask = MockNetworkTask(baseURL: .url(URL(string: "https://mock.sanada.com")!),
                                       path: "/path",
                                       method: .get,
                                       params: [:],
                                       encoding: .queryString,
                                       headers: nil)
        
        var isLoading: Bool?
        var onSuccessResponse: MockNetworkModel? = nil
        var onErrorCalled = false
        var onMapErrorCalled = false
        
        let networkManager = NetworkManager<MockNetworkTask>()
        networkManager.request(mockTask,
                               map: MockNetworkModel.self,
                               session: mockSession,
                               onLoading: { loading in
                                   isLoading = loading
                               },
                               onSuccess: { response in
                                   onSuccessResponse = response
                               },
                               onError: { error in
                                   onErrorCalled = true
                               },
                               onMapError: { data in
                                    onMapErrorCalled = true
                               })
        
        XCTAssertTrue(isLoading!)
        
        XCTAssertTrue(mockSession.dataTaskCalled)
        
        mockDataTask?.resume()
        
        XCTAssertNil(onSuccessResponse)
        
        XCTAssertFalse(onErrorCalled)
        XCTAssertTrue(onMapErrorCalled)
        
        XCTAssertFalse(isLoading!)
    }

}
