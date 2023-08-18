//
//  Helper.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

public struct Helper {
    public static func print(_ message: Any) {
        #if DEBUG
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "dd/MM/YYYY - HH:mm:ss"
        let date = formatter.string(from: Date())
        Swift.print("👾 \(date) - \(message)")
        #endif
    }
}
