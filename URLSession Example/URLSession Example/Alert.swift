//
//  Alert.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import UIKit

internal struct Alert {
    static func createSimpleAlert(title: String,
                                  message: String,
                                  action: (() -> ())? = nil) -> UIAlertController {
        let alert = UIAlertController(
             title: title,
             message: message,
             preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ok", style: .default) { _ in action?() }
        
        alert.addAction(action)
        
        return alert
    }
}
