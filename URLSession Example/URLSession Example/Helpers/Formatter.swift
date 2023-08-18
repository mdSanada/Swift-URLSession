//
//  Formatter.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

internal struct Formatter {
    static func formatNumberToThreeDigits(_ number: Int) -> String {
        return String(format: "%03d", number)
    }
}
