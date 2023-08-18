//
//  ViewController.swift
//  URLSession Example
//
//  Created by Matheus Sanada on 18/08/23.
//

import UIKit
import URLSession_Framework

class ViewController: UIViewController {
    let repository = PokemonRepository()
    @IBOutlet weak var fieldSearchPokemon: UITextField!
    @IBOutlet weak var labelPokemonName: UILabel!
    @IBOutlet weak var imagePokemon: UIImageView!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var imagePokeball: UIImageView!
    
    deinit {
        imagePokeball.layer.removeAllAnimations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelPokemonName.text = ""
        imagePokemon.image = nil
        loading(false)
        handleBackgroundTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rotate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imagePokeball.layer.removeAllAnimations()
    }
    
    private func handleBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        fieldSearchPokemon.resignFirstResponder()
    }

    private func setImage(image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.imagePokemon.image = image
            self?.imagePokemon.contentMode = .scaleAspectFit
        }
    }
    
    private func configure(pokemon: Pokemon) {
        DispatchQueue.main.async { [weak self] in
            self?.labelPokemonName.text = pokemon.name?.capitalized ?? ""
            self?.fieldSearchPokemon.text = ""
        }
    }
    
    private func loading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            if loading {
                self?.buttonSearch.configuration?.showsActivityIndicator = true
                self?.buttonSearch.configuration?.title = nil
            } else {
                self?.buttonSearch.configuration?.showsActivityIndicator = false
                self?.buttonSearch.configuration?.title = "Search"
            }
        }
    }
    
    @IBAction func searchPokemon(_ sender: Any) {
        fieldSearchPokemon.resignFirstResponder()
        guard let text = fieldSearchPokemon.text, !text.isEmpty else { return }
        requestPokemon(by: text)
    }
    
    private func onError(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = Alert.createSimpleAlert(title: "An Issue Occurred!",
                                                message: message)
            self?.present(alert, animated: true)
        }
    }
}

// Usage example of URL Session Framework
extension ViewController {
    func requestPokemon(by name: String) {
        repository.pokemon(name: name) { [weak self] loading in
            Helper.print(loading)
            self?.loading(loading)
        } onSuccess: { [weak self] pokemon in
            Helper.print(pokemon)
            self?.getPokemonImage(from: pokemon.id)
            self?.configure(pokemon: pokemon)
        } onError: { [weak self] error in
            Helper.print(error)
            self?.onError(message: "We're sorry, but we couldn't locate the specified Pokémon. Please double-check the name or try again later.")
        }
    }
    
    func getPokemonImage(from id: Int?) {
        guard let id = id else { return }
        setImage(image: nil)
        let formattedId = Formatter.formatNumberToThreeDigits(id)
        repository.image(from: formattedId) { [weak self] pokemon in
            self?.setImage(image: pokemon)
        } onError: { [weak self] in
            self?.setImage(image: nil)
            self?.onError(message: "We apologize, but we're unable to render the image at the moment. This could be due to a technical issue. ")
            Helper.print("Somethings Wrong happen")
        }
    }
}

// Animation
extension ViewController {
    private func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = -Double.pi
        rotation.duration = 6
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imagePokeball.layer.add(rotation, forKey: "rotationAnimation")
    }
}

