//
//  NetworkManager.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

public class NetworkManager<N: NetworkTask>: Requestable {
    public init() { }
    
    deinit {
        Helper.print("Deinitializing \(self)")
//        URLSession.shared.invalidateAndCancel()
    }
    
    /// Makes a `request`.
    ///
    /// - parameter network: Enum with `NetworkTask` protocol.
    /// - parameter map: Object with `Decodable` protocol. to map the response.
    /// - parameter session: URL Session, defaults `URLSession.shared`.
    /// - parameter onLoading: Returns the request state `Bool`.
    /// - parameter onSuccess: Returns the `object` mapped.
    /// - parameter onError: Returns an `Error` on request.
    /// - parameter onMapError: Returns an `Data`, when tryied to map an failured.
    ///
    /// - Returns: `Void`.
    public func request<T: Decodable>(_ network: N,
                                      map: T.Type,
                                      session: URLSession = URLSession.shared,
                                      onLoading: @escaping ((Bool) -> ()),
                                      onSuccess: @escaping ((T) -> ()),
                                      onError: @escaping ((NSError) -> ()),
                                      onMapError: ((Data) -> ())? = nil,
                                      isRefreshToken: Bool = false) {
        // MARK: - Creating URL Request
        var urlRequest = createRequest(task: network)
        
        // MARK: - Adding Method to URL Request
        setHTTPMethod(to: &urlRequest, task: network)
        
        // MARK: - Adding Params Body or Query String to URL Request
        setParameters(to: &urlRequest, task: network)
        
        // MARK: - Adding Headers to URL Request
        setHeaders(to: &urlRequest, task: network)

        // MARK: - Creating Task
        let task = createTask(urlRequest,
                              in: session,
                              onLoading: onLoading,
                              onSuccess: onSuccess,
                              onError: onError,
                              onMapError: onMapError)
        
        // MARK: - Request
        request(task)
        if isRefreshToken { return }
        onLoading(true)
        Helper.print("Request: Loading(true)")
    }
}
