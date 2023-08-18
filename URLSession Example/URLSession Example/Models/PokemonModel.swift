//
//  PokemonModel.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import Foundation

// MARK: - Pokemon
struct Pokemon: Codable {
    var id: Int?
    var name: String?
    var order: Int?
    var species: Species?
    var sprites: Sprites?
    var height, weight: Int?
}

// MARK: - Species
struct Species: Codable {
    var name: String?
    var url: String?
}

// MARK: - Sprites
struct Sprites: Codable {
    var backDefault, frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case backDefault = "back_default"
        case frontDefault = "front_default"
    }
}
