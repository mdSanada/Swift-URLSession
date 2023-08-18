//
//  Extension + Dictionary.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

extension Dictionary {
    public var data: Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self,
                                                      options: .prettyPrinted)
            return jsonData
        } catch {
            Helper.print(error.localizedDescription)
            return nil
        }
    }
}
