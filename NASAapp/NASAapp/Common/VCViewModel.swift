//
//  VCViewModel.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import Foundation
import UIKit

protocol VCViewModel {
    var backgroundColor: UIColor { get }
    var hidesBackButton: Bool { get }
    var title: String { get }
    var rightBarButtonItemImage: UIImage? { get }
    var rightBarButtonItem: UIBarButtonItem? { get }
    func rightBarButtonItemAction()
}

extension VCViewModel {
    var backgroundColor: UIColor {
        Configuration.Color.defaultViewBackground
    }
    
    var hidesBackButton: Bool {
        false
    }
    
    var title: String {
        String(describing: self).replacingOccurrences(of: "ViewModel", with: "")
    }
    
    var rightBarButtonItemImage: UIImage? {
        return nil
    }
    
    var rightBarButtonItem: UIBarButtonItem? {
        guard let image = rightBarButtonItemImage else {
            return nil
        }
        
        let button = UIButton(configuration: UIButton.Configuration.plain(),
                              primaryAction: UIAction(image: image,
                                                      handler: { action in
            rightBarButtonItemAction()
        }))

        return UIBarButtonItem(customView: button)
    }
    func rightBarButtonItemAction() {
        
    }
}

class BaseViewModel: VCViewModel {
    
}
