//
//  Extension + Data.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

extension Data {
    internal func map<D: Decodable>(to type: D.Type) -> D? {
        do {
            let response = try JSONDecoder().decode(type.self, from: self)
            return response
        } catch let jsonErr {
            Helper.print(jsonErr)
            return nil
       }
    }
    
    internal var dictionary: [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [String:Any]
            return json
        } catch let jsonErr {
            Helper.print(jsonErr)
            return nil
       }
    }
    
    internal var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}

