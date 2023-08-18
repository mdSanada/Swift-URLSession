//
//  PokemonRepository.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import UIKit
import URLSession_Framework

internal class PokemonRepository {
    internal let manager = NetworkManager<PokemonService>()
    internal let imageManager = ImageDownloader()
    
    internal func pokemon(name: String,
                          onLoading: @escaping ((Bool) -> ()),
                          onSuccess: @escaping ((Pokemon) -> ()),
                          onError: @escaping ((Error) -> ())) {
        manager.request(.pokemon(name),
                        map: Pokemon.self,
                        onLoading: onLoading) { [weak self] pokemon in
            onSuccess(pokemon)
        } onError: { [weak self] error in
            onError(error)
        } onMapError: { [weak self] _ in
            onError(NSError.init(domain: "", code: -1, userInfo: [:]))
        }
    }
    
    internal func image(from id: String,
                        onSuccess: @escaping ((UIImage) -> ()),
                        onError: @escaping (() -> ())) {
        let url = "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/\(id).png"

        imageManager.downloadImage(from: url) { pokemon in
            if let pokemon = pokemon {
                onSuccess(pokemon)
            } else {
                onError()
            }
        }
        
    }
}
