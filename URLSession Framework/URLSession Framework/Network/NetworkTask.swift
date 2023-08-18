//
//  NetworkTask.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

/// Creates an requestable enum.
public protocol NetworkTask {
    /// The target's base `URL`.
    var baseURL: NetworkBaseURL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: NetworkMethod { get }

    /// The type of HTTP task to be performed.
    var params: [String: Any] { get }
    
    /// The type of HTTP task to be performed.
    var encoding: EncodingMethod { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}

public enum EncodingMethod {
    case queryString
    case body
}

public enum NetworkBaseURL {
    case url(URL)
}
