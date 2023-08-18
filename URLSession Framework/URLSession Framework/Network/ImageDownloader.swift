//
//  ImageDownloader.swift
//  URLSession Framework
//
//  Created by Matheus Sanada on 18/08/23.
//

import UIKit

public class ImageDownloader {
    
    public init () { }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL,
                               onFinish: @escaping (UIImage?) -> ()) {
        print("Download Started")
        var image: UIImage? = nil
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            image = UIImage(data: data)
            onFinish(image)
        }
    }
    
    public func downloadImage(from link: String,
                              onFinish: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: link) else { return }
        downloadImage(from: url, onFinish: onFinish)
    }
}
