//
//  NetworkMethod.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

/// `HTTP` Request method.
public struct NetworkMethod: RawRepresentable, Equatable, Hashable {
    /// `DELETE` method.
    public static let delete = NetworkMethod(rawValue: "DELETE")
    /// `GET` method.
    public static let get = NetworkMethod(rawValue: "GET")
    /// `PATCH` method.
    public static let patch = NetworkMethod(rawValue: "PATCH")
    /// `POST` method.
    public static let post = NetworkMethod(rawValue: "POST")
    /// `PUT` method.
    public static let put = NetworkMethod(rawValue: "PUT")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension NetworkMethod {
    /// `HTTP Method`
    var httpMethod: String {
        self.rawValue
    }
}
