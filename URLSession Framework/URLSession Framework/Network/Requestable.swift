//
//  Requestable.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

internal protocol Requestable {
    func createRequest(task: NetworkTask) -> URLRequest
    func setHTTPMethod(to request: inout URLRequest, task: NetworkTask)
    func setHeaders(to request: inout URLRequest, task: NetworkTask)
    func setParameters(to request: inout URLRequest, task: NetworkTask)
    func createTask<T: Decodable>(_ request: URLRequest,
                                  in session: URLSession,
                                  onLoading: @escaping ((Bool) -> ()),
                                  onSuccess: @escaping ((T) -> ()),
                                  onError: @escaping ((NSError) -> ()),
                                  onMapError: ((Data) -> ())?) -> URLSessionDataTask
    func request(_ task: URLSessionDataTask)
}

extension Requestable {
    internal func createRequest(task: NetworkTask) -> URLRequest {
        var baseUrl: URL?
        switch task.baseURL {
        case .url(let url):
            baseUrl = url
        }
        let path = task.path
        // MARK: - Base URL with Path
        baseUrl = baseUrl?.appendingPathComponent(path)
        return URLRequest(url: baseUrl!,
                          cachePolicy: .reloadIgnoringCacheData,
                          timeoutInterval: 20)
    }
    
    internal func setHTTPMethod(to request: inout URLRequest, task: NetworkTask) {
        request.httpMethod = task.method.httpMethod
    }
    
    internal func setParameters(to request: inout URLRequest, task: NetworkTask) {
        switch task.encoding {
        case .queryString:
            appendQueryString(to: &request, task: task)
        case .body:
            appendBody(to: &request, task: task)
        }
    }
    
    private func appendBody(to request: inout URLRequest, task: NetworkTask) {
        guard !task.params.isEmpty else {
            return
        }
        request.httpBody = task.params.data
    }
    
    private func appendQueryString(to request: inout URLRequest, task: NetworkTask) {
        var url: URL? {
            guard let scheme = request.url?.scheme,
                  let host = request.url?.host,
                  let path = request.url?.path,
                  let url = request.url else {
                      return request.url
                  }
            guard !task.params.isEmpty else {
                return url
            }
            let queryItems = task.params.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = queryItems
            return components.url
        }
        if let url = url {
            request = URLRequest(url: url,
                                 cachePolicy: request.cachePolicy,
                                 timeoutInterval: request.timeoutInterval)
        }
    }
    
    internal func setHeaders(to request: inout URLRequest, task: NetworkTask) {
        if let headers = task.headers {
            request.allHTTPHeaderFields = headers
            
            if headers["Content-Type"] == nil,
               task.encoding == .body {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
    }
    
    internal func createTask<T: Decodable>(_ request: URLRequest,
                                           in session: URLSession,
                                           onLoading: @escaping ((Bool) -> ()),
                                           onSuccess: @escaping ((T) -> ()),
                                           onError: @escaping ((NSError) -> ()),
                                           onMapError: ((Data) -> ())?) -> URLSessionDataTask {
        session.dataTask(with: request) { (data, response, error) in
            if !(getStatusCode(from: response) == 401) {
                Helper.print("Request: Loading(false)")
                onLoading(false)
            }
            // Check for Error
            if let error = error {
                onError(NSError(domain: request.url?.description ?? "",
                                code: -1,
                                userInfo: [:]))
                return
            }

            // Convert HTTP Response Data
            if let data = data {
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        guard let object = data.map(to: T.self) else {
                            Helper.print("Request: Map Error")
                            if let onMapError = onMapError {
                                onMapError(data)
                            } else {
                                onError(NSError(domain: request.url?.description ?? "",
                                                code: httpResponse.statusCode,
                                                userInfo: [:]))
                            }
                            return
                        }
                        Helper.print("Request: Success")
                        onSuccess(object)
                    } else {
                        Helper.print("Request: Error")
                        let code = getStatusCode(from: response)
                        onError(NSError(domain: request.description,
                                        code: code,
                                        userInfo: data.dictionary))
                    }
                }
            } else {
                Helper.print("Request: Data Error")
                let code = getStatusCode(from: response)
                onError(NSError(domain: request.description,
                                code: code,
                                userInfo: nil))
            }
        }
    }
    
    internal func getStatusCode(from urlResponse: URLResponse?) -> Int {
        if let httpResponse = urlResponse as? HTTPURLResponse {
            return httpResponse.statusCode
        } else {
            return -1
        }
    }

    internal func request(_ task: URLSessionDataTask) {
        Helper.print("Request: \(task.currentRequest?.url?.description ?? "")")
        task.resume()
    }
}
