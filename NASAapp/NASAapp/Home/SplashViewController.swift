//
//  SplashViewController.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit

protocol SplashViewControllerDelegate: AnyObject {
    func didFinishAnimating()
}

class SplashViewController: BaseViewController {
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(image: Images.logotype)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    weak var delegate: SplashViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        
        view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -96).isActive = true
        view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 96).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, constant: 0).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: AnimationDurations.mediumAnimationDuration,
                       delay: AnimationDurations.mediumAnimationDuration,
                       options: .curveEaseInOut) {
            self.imageView.alpha = 0.0
            self.imageView.transform = self.imageView.transform.scaledBy(x: 3, y: 3)
            
        } completion: { completed in
            self.delegate?.didFinishAnimating()
        }

    }
}

