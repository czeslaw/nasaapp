//
//  UIImageView+.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    @discardableResult
    func imageFromURL(url: URL?, placeholder: UIImage? = Images.feedPlaceholder) -> URLSessionTask? {
        guard let url = url else { image = placeholder; return nil }

        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            image = cachedImage
            return nil
        }

        image = placeholder

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            guard (error as NSError?)?.code != NSURLErrorCancelled, data != nil else {
                return
            }

            guard error == nil else {
                DispatchQueue.main.async { self.image = placeholder }
                return
            }

            DispatchQueue.main.async {
                if let data = data,
                    let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    self.image = image
                } else {
                    self.image = placeholder
                }
            }
        })
        task.resume()
        return task
    }
}
