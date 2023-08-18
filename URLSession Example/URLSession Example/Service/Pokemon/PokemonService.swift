//
//  PokemonService.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation
import URLSession_Framework

internal enum PokemonService: NetworkTask {
    case pokemon(String)
}

extension PokemonService {
    var baseURL: NetworkBaseURL {
        guard let url = URL(string: "https://pokeapi.co/") else {
            fatalError("Base URL Invalid")
        }
        return .url(url)
    }
    
    var path: String {
        switch self {
        case .pokemon(let pokemon):
            return "api/v2/pokemon/\(pokemon.lowercased())"
        }
    }
    
    var method: NetworkMethod {
        switch self {
        case .pokemon:
            return .get
        }
    }
    
    var params: [String : Any] {
        switch self {
        case .pokemon:
            return [:]
        }
    }
    
    var encoding: EncodingMethod {
        switch self {
        case .pokemon:
            return .queryString
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .pokemon:
            return nil
        }
    }
}
